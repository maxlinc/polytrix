require 'polytrix/reporters'
module Polytrix
  module Command
    class Show < Polytrix::Command::Base
      include Polytrix::Reporters
      include Polytrix::Core::FileSystemHelper

      def initialize(cmd_args, cmd_options, options = {})
        @indent_level = 0
        super
      end

      def call
        setup
        @reporter = Polytrix::Reporters.reporter(options[:format], shell)
        tests = parse_subcommand(args.first)
        tests.keep_if { |test| test.failed? == options[:failed] } unless options[:failed].nil?
        tests.keep_if { |test| test.skipped? == options[:skipped] } unless options[:skipped].nil?

        tests.each do | test |
          status(test.status_description, test.slug, test.status_color.to_sym)
          indent do
            status('Test suite:', test.suite)
            status('Test scenario:', test.name)
            status('Implementor:', test.implementor.name)
            source_file = test.absolute_source_file ? relativize(test.absolute_source_file, Dir.pwd) : colorize('<No code sample>', :red)
            status('Source:', source_file)
            display_execution_result(test)
            display_validations(test)
            display_spy_data(test)
          end
        end
      end

      private

      def reformat(string)
        return if string.nil? || string.empty?

        indent do
          string.gsub(/^/, indent)
        end
      end

      def indent
        if block_given?
          @indent_level += 2
          result = yield
          @indent_level -= 2
          result
        else
          ' ' * @indent_level
        end
      end

      def display_execution_result(test)
        return unless test.result && test.result.execution_result

        execution_result = test.result.execution_result
        indent do
          status 'Execution result:'
          indent do
            status('Exit Status:', execution_result.exitstatus)
            status 'Stdout:'
            say reformat(execution_result.stdout)
            status 'Stderr:'
            say reformat(execution_result.stderr)
          end
        end if execution_result
      end

      def display_validations(test)
        return unless test.validations

        status 'Validations:'
        indent do
          test.validations.each do | validation |
            status(validation)
          end
        end
      end

      def display_spy_data(test)
        return unless test.spy_data

        status 'Data from spies:'
        indent do
          test.spy_data.each do |spy, data|
            indent do
              data.each_pair do |k, v|
                status(k, v)
              end
            end
          end
        end
      end

      def say(msg)
        shell.say msg if msg
      end

      def status(status, msg = nil, color = :cyan)
        msg = yield if block_given?
        if msg.nil?
          # This is to avoid trailing spaces that say_status produces if msg is nil
          msg = shell.set_color(indent + status, color, true)
          shell.say msg
        else
          shell.say_status(indent + status, msg, color)
        end
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
    end
  end
end