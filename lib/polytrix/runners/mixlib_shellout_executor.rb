require 'mixlib/shellout'

module Polytrix
  module Runners
    class MixlibShellOutExecutor
      def execute(command, opts)
        prefix = opts.delete :prefix
        shell = Mixlib::ShellOut.new(command, opts)
        shell.live_stream = OutputDecorator.new($stdout, prefix) unless Polytrix.configuration.suppress_output
        shell.run_command
        execution_result = ExecutionResult.new exitstatus: shell.exitstatus, stdout: shell.stdout, stderr: shell.stderr
        begin
          shell.error!
        rescue Mixlib::ShellOut::ShellCommandFailed => e
          execution_error = ExecutionError.new(e)
          execution_error.execution_result = execution_result
          raise execution_error
        end

        execution_result
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
