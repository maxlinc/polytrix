require 'benchmark'

module Polytrix
  module Command
    class ImplementorAction < Polytrix::Command::Base
      include RunAction

      # Invoke the command.
      def call
        banner "Starting Polytrix (v#{Polytrix::VERSION})"
        elapsed = Benchmark.measure do
          setup
          task = args.shift
          sdk_regex = args.shift
          sdks = Polytrix.filter_sdks(sdk_regex)
          run_action(action, sdks, task)
        end
        banner "Polytrix is finished. #{Util.duration(elapsed.real)}"
      end
    end
  end
end
