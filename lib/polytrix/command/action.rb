require 'benchmark'

module Polytrix
  module Command
    class Action < Polytrix::Command::Base
      include RunAction

      # Invoke the command.
      def call
        shell.say "Starting Polytrix (v#{Polytrix::VERSION})"
        elapsed = Benchmark.measure do
          # results = parse_subcommand(args.first)
          setup
          Logging.mdc['command'] = action
          if @args.empty?
            Polytrix.public_send action
          else
            Polytrix.public_send action, *@args
          end
          # run_action(action, results)
        end
        # banner "Kitchen is finished. #{Util.duration(elapsed.real)}"
        shell.say "Polytrix is finished. #{elapsed.real}"
      end
    end
  end
end
