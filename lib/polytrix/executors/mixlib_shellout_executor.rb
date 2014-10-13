require 'mixlib/shellout'

module Polytrix
  module Executors
    class IOToLog < IO
      def initialize(logger)
        @logger = logger
        @buffer = ''
      end

      def write(string)
        (@buffer + string).lines.each do |line|
          if line.end_with? "\n"
            @buffer = ''
            @logger.info(line.rstrip)
          else
            @buffer = line
          end
        end
      end
    end

    class MixlibShellOutExecutor
      include Polytrix::DefaultLogger

      MIXLIB_SHELLOUT_EXCEPTION_CLASSES = Mixlib::ShellOut.constants.map do|name|
        klass = Mixlib::ShellOut.const_get(name)
        if klass.is_a?(Class) && klass <= RuntimeError
          klass
        else
          nil
        end
      end.compact

      def log_decorator(_io, _prefix)
        IOToLog.new(logger)
      end

      def execute(command, opts)
        prefix = opts.delete :prefix
        shell = Mixlib::ShellOut.new(command, opts)
        shell.live_stream = log_decorator $stdout, prefix
        shell.run_command
        execution_result = ExecutionResult.new exitstatus: shell.exitstatus, stdout: shell.stdout, stderr: shell.stderr
        # shell.error!
        execution_result
      rescue SystemCallError, *MIXLIB_SHELLOUT_EXCEPTION_CLASSES, TypeError => e
        # See https://github.com/opscode/mixlib-shellout/issues/62
        execution_error = ExecutionError.new(e)
        execution_error.execution_result = execution_result
        raise execution_error
      end
    end
  end
end
