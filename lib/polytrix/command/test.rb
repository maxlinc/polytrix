require 'polytrix/command'

require 'benchmark'

module Polytrix
  module Command
    # Command to test one or more instances.
    class Test < Polytrix::Command::Base
      include RunAction

      # Invoke the command.
      def call
        banner "Starting Polytrix (v#{Polytrix::VERSION})"
        elapsed = Benchmark.measure do
          setup
          results = parse_subcommand(args.shift, args.shift)

          run_action(:test, results)
        end
        banner "Polytrix is finished. #{Util.duration(elapsed.real)}"
      end
    end
  end
end
