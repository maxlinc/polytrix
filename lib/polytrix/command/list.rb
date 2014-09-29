require 'polytrix/reporters'
module Polytrix
  module Command
    class List < Polytrix::Command::Base
      include Polytrix::Reporters

      def call
        setup
        @reporter = Polytrix::Reporters.reporter(options[:format], shell)
        tests = parse_subcommand(args.first)

        table = [
          [
            colorize('Suite', :green), colorize('Scenario', :green),
            colorize('Implementor', :green), colorize('Status', :green)
          ]
        ]
        table += tests.map do | challenge |
          [
            color_pad(challenge.suite),
            color_pad(challenge.name),
            color_pad(challenge.implementor.name),
            format_last_action(challenge)
          ]
        end
        print_table(table)
      end

      private

      def print_table(*args)
        @reporter.print_table(*args)
      end

      def colorize(string, *args)
        return string unless @reporter.respond_to? :set_color
        @reporter.set_color(string, *args)
      end

      def color_pad(string)
        string + colorize('', :white)
      end

      def format_last_action(challenge)
        case challenge.last_action
        when 'clone' then colorize('Cloned', :cyan)
        when 'bootstrap' then colorize('Bootstrapped', :magenta)
        when 'exec' then colorize('Executed', :blue)
        when 'verify' then verification_message(challenge)
        when nil then colorize('<Not Found>', :red)
        else colorize("<Unknown (#{challenge.last_action})>", :white)
        end
      end

      def verification_message(challenge)
        validator_count = challenge.validators.count
        validation_count = challenge.validators.count
        if validator_count == validation_count
          colorize("Fully Verified (#{validation_count} of #{validator_count})", :green)
        else
          colorize("Partially Verified (#{validation_count} of #{validator_count})", :yellow)
        end
      end
    end
  end
end
