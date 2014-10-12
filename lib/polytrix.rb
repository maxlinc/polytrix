require 'thor'
require 'pathname'
require 'polytrix/error'
require 'polytrix/core/hashie'
require 'polytrix/core/string_helpers'
require 'polytrix/version'
require 'polytrix/util'
require 'polytrix/color'
require 'polytrix/logger'
require 'polytrix/logging'
require 'polytrix/state_file'
require 'polytrix/core/file_system_helper'
require 'polytrix/spies'
# TODO: Merge these two classes?
require 'polytrix/executor'
require 'polytrix/challenge_runner'
require 'polytrix/core/manifest_section'
require 'polytrix/core/implementor'
require 'polytrix/challenge_result'
require 'polytrix/challenge'
require 'polytrix/challenges'
require 'polytrix/manifest'
require 'polytrix/configuration'
require 'polytrix/validation'
require 'polytrix/result'
require 'polytrix/documentation_generator'
require 'polytrix/validator'
require 'polytrix/validator_registry'

module Polytrix
  include Polytrix::DefaultLogger
  include Polytrix::Logging

  class << self
    include Polytrix::Core::FileSystemHelper

    # @return [Mutex] a common mutex for global coordination
    attr_accessor :mutex

    # @return [Logger] the common Polytrix logger
    attr_accessor :logger

    # Returns a default file logger which emits on standard output and to a
    # log file.
    #
    # @return [Logger] a logger
    def default_file_logger
      logfile = File.expand_path(File.join('.polytrix', 'logs', 'polytrix.log'))
      Logger.new(stdout: $stdout, logdev: logfile, level: env_log)
    end

    # Determine the default log level from an environment variable, if it is
    # set.
    #
    # @return [Integer,nil] a log level or nil if not set
    # @api private
    def env_log
      level = ENV['POLYTRIX_LOG'] && ENV['POLYTRIX_LOG'].downcase.to_sym
      level = Util.to_logger_level(level) unless level.nil?
      level
    end

    # Default log level verbosity
    DEFAULT_LOG_LEVEL = :info

    def reset
      @configuration = nil
      Polytrix::ValidatorRegistry.clear
    end

    # The {Polytrix::Manifest} that describes the test scenarios known to Polytrix.
    def manifest
      configuration.manifest
    end

    # The set of {Polytrix::Implementor}s registered with Polytrix.
    def implementors
      manifest.implementors.values
    end

    def find_implementor(file)
      existing_implementor = recursive_parent_search(File.dirname(file)) do |path|
        implementors.find do |implementor|
          File.absolute_path(implementor.basedir) == File.absolute_path(path)
        end
      end
      return existing_implementor if existing_implementor

      nil
    end

    # Invokes the clone action for each SDK.
    # @see Polytrix::Implementor#clone
    def clone(*sdks)
      select_implementors(sdks).each do |implementor|
        implementor.clone
      end
    end

    # Invokes the bootstrap  action for each SDK.
    # @see Polytrix::Implementor#bootstrap
    def bootstrap(*sdks)
      select_implementors(sdks).each do |implementor|
        implementor.bootstrap
      end
    end

    def exec(*files)
      # files.map do | file |
      #   Dir.glob file
      # end.flatten

      files.each do | file |
        implementor = find_implementor(file) # || exec_options[:default_implementor]

        extension = File.extname(file)
        name = File.basename(file, extension)
        challenge_data = {
          name: name,
          # language: extension,
          source_file: File.expand_path(file, Dir.pwd)
        }
        challenge = implementor.build_challenge challenge_data
        challenge.exec
      end
    end

    # Registers a {Polytrix::Validator} that will be used during test
    # execution on matching {Polytrix::Challenge}s.
    def validate(desc, scope = { suite: //, sample: // }, &block)
      fail ArgumentError 'You must pass block' unless block_given?
      validator = Polytrix::Validator.new(desc, scope, &block)

      Polytrix::ValidatorRegistry.register validator
      validator
    end

    def reset
      @configuration = nil
    end

    # @see Polytrix::Configuration
    def configuration
      fail "configuration doesn't take a block, use configure" if block_given?
      @configuration ||= Configuration.new
    end

    # @see Polytrix::Configuration
    def configure
      yield(configuration)
    end

    # Returns whether or not standard output is associated with a terminal
    # device (tty).
    #
    # @return [true,false] is there a tty?
    def tty?
      $stdout.tty?
    end

    protected

    def select_implementors(sdks)
      return implementors if sdks.empty?

      sdks.map do |sdk|
        if File.directory? sdk
          sdk_dir = File.absolute_path(sdk)
          implementors.find { |i| File.absolute_path(i.basedir) == sdk_dir } || configuration.implementor(sdk_dir)
        else
          implementor = implementors.find { |i| i.name.to_s.downcase == sdk.to_s.downcase }
          fail ArgumentError, "SDK #{sdk} not found" if implementor.nil?
          implementor
        end
      end
    end
  end
end

Polytrix.mutex = Mutex.new
