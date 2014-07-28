require "polytrix/command"

require "benchmark"

module Polytrix

  module Command

    # Command to test one or more instances.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class Test < Kitchen::Command::Base

      include RunAction

      # Invoke the command.
      def call
        banner "Starting Kitchen (v#{Kitchen::VERSION})"
        elapsed = Benchmark.measure do
          results = parse_subcommand(args.join("|"))

          run_action(:test, results, destroy_mode)
        end
        banner "Kitchen is finished. #{duration(elapsed.real)}"
      end
    end
  end
end
