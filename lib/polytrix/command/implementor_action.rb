require 'benchmark'

module Polytrix
  module Command
    class ProjectAction < Polytrix::Command::Base
      include RunAction

      # Invoke the command.
      def call
        banner "Starting Polytrix (v#{Polytrix::VERSION})"
        elapsed = Benchmark.measure do
          setup
          task = args.shift
          project_regex = args.shift
          projects = Polytrix.filter_projects(project_regex)
          run_action(action, projects, task)
        end
        banner "Polytrix is finished. #{Util.duration(elapsed.real)}"
      end
    end
  end
end
