module Polytrix
  module Command
    class List < Polytrix::Command::Base
      def call
        # Logging.mdc['command'] = 'list'

        setup
        Polytrix.manifest.build_challenges

        table = [
          [
            colorize('Suite', :green), colorize('Scenario', :green),
            colorize('Implementor', :green), colorize('Status', :green)
          ]
        ]
        table += Polytrix.manifest.challenges.values.map do | challenge |
          [
            color_pad(challenge.suite),
            color_pad(challenge.name),
            color_pad(challenge.implementor.name),
            format_last_action(challenge)
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

      def format_last_action(challenge)
        case challenge.last_action
        when 'clone' then colorize('Cloned', :cyan)
        when 'bootstrap' then colorize('Bootstrapped', :magenta)
        when 'exec' then colorize('Executed', :blue)
        when 'verify' then colorize("Verified (Level #{challenge.verification_level})", :yellow)
        when nil then colorize('<Not Found>', :red)
        else colorize("<Unknown (#{challenge.last_action})>", :white)
        end
      end
    end
  end
end
