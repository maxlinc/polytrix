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
            colorize('Test ID', :green), colorize('Suite', :green), colorize('Scenario', :green),
            colorize('Implementor', :green), colorize('Status', :green)
          ]
        ]
        table += tests.map do | challenge |
          [
            color_pad(challenge.slug),
            color_pad(challenge.suite),
            color_pad(challenge.name),
            color_pad(challenge.implementor.name),
            format_status(challenge)
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

      def format_status(challenge)
        colorize(challenge.status_description, challenge.status_color)
      end
    end
  end
end
