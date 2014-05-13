require 'hashie/dash'

module Polytrix
  module Executor
    class ExecutionResult < Hashie::Dash
      property :exitstatus, :require => true
      property :stdout, :required => true
      property :stderr, :required => true
    end

    class InteractiveExecutor
      def execute(command, opts)
        system command
        # Fixme: This needs to return execution result, if interactive remains supported
      end
    end

    class ShellOutExecutor
      def execute(command, opts)
        shell = Mixlib::ShellOut.new(command, opts)
        shell.live_stream = $stdout unless Polytrix.configuration.suppress_output
        shell.run_command
        shell.error!
        ExecutionResult.new :exitstatus => shell.exitstatus, :stdout => shell.stdout, :stderr => shell.stderr
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
