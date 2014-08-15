module Polytrix
  module Command
    class List < Polytrix::Command::Base
      def call
        Logging.mdc['command'] = 'list'

        setup
        Polytrix.manifest.build_challenges

        table = [
          [
            colorize('Scenario', :green), colorize('Suite', :green),
            colorize('Implementor', :green), colorize('Status', :green)
          ]
        ]
        table += Polytrix.manifest.challenges.values.map do | challenge |
          [
            color_pad(challenge.name),
            color_pad(challenge.suite),
            color_pad(challenge.implementor.name),
            colorize('Unknown', :red)
          ]
        end
        shell.print_table table
      end

      private

      def print_table(*args)
        shell.print_table(*args)
      end

      def colorize(string, *args)
        shell.set_color(string, *args)
      end

      def color_pad(string)
        string + colorize('', :white)
      end
    end
  end
end
