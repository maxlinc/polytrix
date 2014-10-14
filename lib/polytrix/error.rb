require 'English'

module Polytrix
  # All Polytrix errors and exceptions.
  module Error
    # Creates an array of strings, representing a formatted exception,
    # containing backtrace and nested exception info as necessary, that can
    # be viewed by a human.
    #
    # For example:
    #
    #     ------Exception-------
    #     Class: Polytrix::StandardError
    #     Message: Failure starting the party
    #     ---Nested Exception---
    #     Class: IOError
    #     Message: not enough directories for a party
    #     ------Backtrace-------
    #     nil
    #     ----------------------
    #
    # @param exception [::StandardError] an exception
    # @return [Array<String>] a formatted message
    def self.formatted_trace(exception)
      arr = formatted_exception(exception).dup
      last = arr.pop
      if exception.respond_to?(:original) && exception.original
        arr += formatted_exception(exception.original, 'Nested Exception')
        last = arr.pop
      end
      arr += ['Backtrace'.center(22, '-'), exception.backtrace, last].flatten
      arr
    end

    # Creates an array of strings, representing a formatted exception that
    # can be viewed by a human. Thanks to MiniTest for the inspiration
    # upon which this output has been designed.
    #
    # For example:
    #
    #     ------Exception-------
    #     Class: Polytrix::StandardError
    #     Message: I have failed you
    #     ----------------------
    #
    # @param exception [::StandardError] an exception
    # @param title [String] a custom title for the message
    #   (default: `"Exception"`)
    # @return [Array<String>] a formatted message
    def self.formatted_exception(exception, title = 'Exception')
      [
        title.center(22, '-'),
        "Class: #{exception.class}",
        "Message: #{exception.message}",
        ''.center(22, '-')
      ]
    end
  end

  # Base exception class from which all Polytrix exceptions derive. This class
  # nests an exception when this class is re-raised from a rescue block.
  class StandardError < ::StandardError
    include Error

    # @return [::StandardError] the original (wrapped) exception
    attr_reader :original

    # Creates a new StandardError exception which optionally wraps an original
    # exception if given or detected by checking the `$!` global variable.
    #
    # @param msg [String] exception message
    # @param original [::StandardError] an original exception which will be
    #   wrapped (default: `$ERROR_INFO`)
    def initialize(msg, original = $ERROR_INFO)
      super(msg)
      @original = original
    end
  end

  # Base exception class for all exceptions that are caused by user input
  # errors.
  class UserError < StandardError; end

  # Base exception class for all exceptions that are caused by incorrect use
  # of an API.
  class ClientError < StandardError; end

  # Base exception class for exceptions that are caused by external library
  # failures which may be temporary.
  class TransientFailure < StandardError; end

  # Exception class for any exceptions raised when performing an challenge
  # action.
  class ActionFailed < TransientFailure; end

  # Exception class capturing what caused an challenge to die.
  class ChallengeFailure < TransientFailure; end

  # Exception class capturing what caused a validation to fail.
  class ValidationFailure < TransientFailure; end

  class ExecutionError < TransientFailure
    attr_accessor :execution_result
  end

  class << self
    # Yields to a code block in order to consistently emit a useful crash/error
    # message and exit appropriately. There are two primary failure conditions:
    # an expected challenge failure, and any other unexpected failures.
    #
    # **Note** This method may call `Kernel.exit` so may not return if the
    # yielded code block raises an exception.
    #
    # ## Challenge Failure
    #
    # This is an expected failure scenario which could happen if an challenge
    # couldn't be created, a Chef run didn't successfully converge, a
    # post-convergence test suite failed, etc. In other words, you can count on
    # encountering these failures all the time--this is Polytrix's worldview:
    # crash early and often. In this case a cleanly formatted exception is
    # written to `STDERR` and the exception message is written to
    # the common Polytrix file logger.
    #
    # ## Unexpected Failure
    #
    # All other forms of `Polytrix::Error` exceptions are considered unexpected
    # or unplanned exceptions, typically from user configuration errors, driver
    # or provisioner coding issues or bugs, or internal code issues. Given
    # a stable release of Polytrix and a solid set of drivers and provisioners,
    # the most likely cause of this is user configuration error originating in
    # the `.polytrix.yml` setup. For this reason, the exception is written to
    # `STDERR`, a full formatted exception trace is written to the common
    # Polytrix file logger, and a message is displayed on `STDERR` to the user
    # informing them to check the log files and check their configuration with
    # the `polytrix diagnose` subcommand.
    #
    # @raise [SystemExit] if an exception is raised in the yielded block
    def with_friendly_errors
      yield
    rescue Polytrix::ChallengeFailure => e
      Polytrix.mutex.synchronize do
        handle_challenge_failure(e)
      end
      exit 10
    rescue Polytrix::Error => e
      Polytrix.mutex.synchronize do
        handle_error(e)
      end
      exit 20
    end

    # Handles an challenge failure exception.
    #
    # @param e [StandardError] an exception to handle
    # @see Polytrix.with_friendly_errors
    # @api private
    def handle_challenge_failure(e)
      stderr_log(e.message.split(/\s{2,}/))
      stderr_log(Error.formatted_exception(e.original))
      file_log(:error, e.message.split(/\s{2,}/).first)
      debug_log(Error.formatted_trace(e))
    end

    alias_method :handle_validation_failure, :handle_challenge_failure

    # Handles an unexpected failure exception.
    #
    # @param e [StandardError] an exception to handle
    # @see Polytrix.with_friendly_errors
    # @api private
    def handle_error(e)
      stderr_log(Error.formatted_exception(e))
      stderr_log('Please see .polytrix/logs/polytrix.log for more details')
      # stderr_log("Also try running `polytrix diagnose --all` for configuration\n")
      file_log(:error, Error.formatted_trace(e))
    end

    private

    # Writes an array of lines to the common Polytrix logger's file device at the
    # given severity level. If the Polytrix logger is set to debug severity, then
    # the array of lines will also be written to the console output.
    #
    # @param level [Symbol,String] the desired log level
    # @param lines [Array<String>] an array of strings to log
    # @api private
    def file_log(level, lines)
      Array(lines).each do |line|
        if Polytrix.logger.debug?
          Polytrix.logger.debug(line)
        else
          Polytrix.logger.logdev && Polytrix.logger.logdev.public_send(level, line)
        end
      end
    end

    # Writes an array of lines to the `STDERR` device.
    #
    # @param lines [Array<String>] an array of strings to log
    # @api private
    def stderr_log(lines)
      Array(lines).each do |line|
        $stderr.puts(Color.colorize(">>>>>> #{line}", :red))
      end
    end

    # Writes an array of lines to the common Polytrix debugger with debug
    # severity.
    #
    # @param lines [Array<String>] an array of strings to log
    # @api private
    def debug_log(lines)
      Array(lines).each { |line| Polytrix.logger.debug(line) }
    end
  end
end
