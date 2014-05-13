module Polytrix
  module Executor
    class InteractiveExecutor
      def execute(command, opts)
        system command
      end
    end

    class ShellOutExecutor
      def execute(command, opts)
        shell = Mixlib::ShellOut.new(command, opts)
        shell.live_stream = $stdout unless Polytrix.configuration.suppress_output
        shell.run_command
        shell.error!
        shell
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
