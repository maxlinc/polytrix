require 'mixlib/shellout'

module Polytrix
  module Runners
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

      def log_decorator(io, prefix)
        # OutputDecorator.new(io, prefix) unless Polytrix.configuration.suppress_output
        # logger = Logging.logger['polytrix::exec']
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

      class OutputDecorator
        # Reserve :red, :black, :white
        COLORS = [:green, :yellow, :blue, :magenta, :cyan]

        def self.next_color
          @next_color ||= 0
          @next_color += 1
          COLORS[@next_color % COLORS.size]
        end

        def initialize(real_io, prefix = nil)
          @real_io = real_io
          # @prefix = set_color(prefix, :cyan)
          @prefix = "#{prefix}: " if prefix
          @color = self.class.next_color
          @thor_shell = Thor::Shell::Color.new
        end

        def puts(line)
          line = line.gsub(/^/, @prefix) if @prefix
          @real_io.puts @thor_shell.set_color(line, @color)
        end

        def <<(line)
          line = line.gsub(/^/, @prefix) if @prefix
          @real_io << @thor_shell.set_color(line, @color)
        end

        def method_missing(meth, *args, &block)
          @real_io.send meth, *args, &block
        end
      end
    end
  end
end
