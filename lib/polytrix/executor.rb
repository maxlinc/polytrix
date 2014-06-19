require 'hashie/dash'
require 'thor'

module Polytrix
  module Executor
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

    class ExecutionResult < Hashie::Dash
      property :exitstatus, require: true
      property :stdout, required: true
      property :stderr, required: true
    end

    class InteractiveExecutor
      def execute(command, opts)
        system command
        # FIXME: This needs to return execution result, if interactive remains supported
      end
    end

    class ShellOutExecutor
      def execute(command, opts)
        prefix = opts.delete :prefix
        shell = Mixlib::ShellOut.new(command, opts)
        shell.live_stream = OutputDecorator.new($stdout, prefix) unless Polytrix.configuration.suppress_output
        shell.run_command
        shell.error!
        ExecutionResult.new exitstatus: shell.exitstatus, stdout: shell.stdout, stderr: shell.stderr
      end
    end

    attr_writer :executor

    def executor
      @executor ||= if ENV['INTERACTIVE']
                      InteractiveExecutor.new
                    else
                      ShellOutExecutor.new
                    end
    end

    def execute(command, opts = {})
      executor.execute(command, opts)
    end
  end
end
