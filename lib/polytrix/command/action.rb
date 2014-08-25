require 'benchmark'

module Polytrix
  module Command
    class Action < Polytrix::Command::Base
      include RunAction

      # Invoke the command.
      def call
        shell.say "Starting Polytrix (v#{Polytrix::VERSION})"
        elapsed = Benchmark.measure do
          setup
          tests = parse_subcommand(args.first)
          implementors = tests.map(&:implementor).uniq
          Logging.mdc['command'] = action
          if [:clone, :bootstrap].include? action # actions on implementors
            run_action(action, implementors)
          else # actions on tests
            run_action(action, tests)
          end
        end
        # banner "Kitchen is finished. #{Util.duration(elapsed.real)}"
        shell.say "Polytrix is finished. #{duration(elapsed.real)}"
      end

      private

      def duration(total)
        total = 0 if total.nil?
        minutes = (total / 60).to_i
        seconds = (total - (minutes * 60))
        format('(%dm%.2fs)', minutes, seconds)
      end
    end
  end
end
