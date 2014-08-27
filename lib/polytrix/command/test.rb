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
          results = parse_subcommand(args.join('|'))

          run_action(:test, results, destroy_mode)
        end
        banner "Polytrix is finished. #{duration(elapsed.real)}"
      end
    end
  end
end
