require 'benchmark'

module Polytrix
  module Command
    class Action < Polytrix::Command::Base
      include RunAction

      IMPLEMENTOR_ACTIONS = [:clone, :bootstrap, :task] # These are run once per project, not per test

      # Invoke the command.
      def call
        banner "Starting Polytrix (v#{Polytrix::VERSION})"
        elapsed = Benchmark.measure do
          setup
          tests = parse_subcommand(args.shift, args.shift)
          projects = tests.map(&:project).uniq
          if IMPLEMENTOR_ACTIONS.include? action # actions on projects
            run_action(action, projects)
          else # actions on tests
            run_action(action, tests)
          end
        end
        banner "Polytrix is finished. #{Util.duration(elapsed.real)}"
      end
    end
  end
end
