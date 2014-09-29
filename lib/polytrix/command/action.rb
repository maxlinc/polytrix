require 'benchmark'

module Polytrix
  module Command
    class Action < Polytrix::Command::Base
      include RunAction

      # Invoke the command.
      def call
        banner "Starting Polytrix (v#{Polytrix::VERSION})"
        elapsed = Benchmark.measure do
          setup
          tests = parse_subcommand(args.pop)
          implementors = tests.map(&:implementor).uniq
          if [:clone, :bootstrap].include? action # actions on implementors
            run_action(action, implementors)
          else # actions on tests
            run_action(action, tests)
          end
        end
        banner "Polytrix is finished. #{Util.duration(elapsed.real)}"
      end
    end
  end
end
