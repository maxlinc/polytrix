require 'polytrix/reporters'
module Polytrix
  module Command
    class List < Polytrix::Command::Base
      include Polytrix::Reporters

      def call
        setup
        @reporter = Polytrix::Reporters.reporter(options[:format], shell)
        tests = parse_subcommand(args.pop)

        table = [header_row]
        table += tests.map do | challenge |
          row(challenge)
        end
        print_table(table)
      end

      private

      def header_row
        row = []
        row << colorize('Test ID', :green)
        row << colorize('Suite', :green)
        row << colorize('Scenario', :green)
        row << colorize('Implementor', :green)
        row << colorize('Status', :green)
        row << colorize('Source', :green) if options[:source]
        row
      end

      def row(challenge)
        row = []
        row << color_pad(challenge.slug)
        row << color_pad(challenge.suite)
        row << color_pad(challenge.name)
        row << color_pad(challenge.implementor.name)
        row << format_status(challenge)
        if options[:source]
          source_file = challenge.absolute_source_file ? relativize(challenge.absolute_source_file, Dir.pwd) : colorize('<No code sample>', :red)
          row << source_file
        end
        row
      end

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
