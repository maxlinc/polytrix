module Polytrix
  module Reporters
    # autoload :TextReporter, 'polytrix/cli/reports/text_reporter'
    autoload :MarkdownReporter, 'polytrix/cli/reports/markdown_reporter'
    # autoload :HTMLReporter, 'polytrix/cli/reports/html_reporter'
    autoload :JSONReporter, 'polytrix/cli/reports/json_reporter'
    autoload :YAMLReporter, 'polytrix/cli/reports/yaml_reporter'
  end
  module Command
    class Report < Polytrix::Command::Base
      def call
        fail StandardError, 'Report command not yet implemented - work in progress'
        # setup
        # @tests = parse_subcommand(args.first)
        # tests_by_implementor = @tests.group_by(&:implementor)

        # table = [
        #   [
        #     colorize('SDK', :green), colorize('Passed', :green),
        #     colorize('Failed', :red), colorize('Pending', :yellow),
        #     colorize('Skipped', :cyan)
        #   ]
        # ]
        # load_results.each do |sdk, sdk_summary|
        #   table << [sdk, sdk_summary[:passed], sdk_summary[:failed], sdk_summary[:pending], sdk_summary[:skipped]]
        # end
        # shell.print_table table
      end

      private

      def count(results, state)
        results.count do |r|
          result.last_action.to_s == state.to_s
        end
      end

      def load_results
        result_stats = Hash.new do |hash, sdk|
          hash[sdk] = { passed: 0, failed: 0, pending: 0, skipped: 0 }
        end
        Polytrix.manifest.suites.reduce(result_stats) do |hash, (suite_name, suite)|
          suite.samples.each do |sample, suite_results|
            Polytrix.implementors.map(&:name).each do |sdk|
              result = Result.new(suite_results[sdk])
              result.validations << Validation.new(validated_by: 'polytrix', result: 'skipped')
              hash[sdk][result.status.to_sym] += 1
            end
          end
          hash
        end
        result_stats
      end

      def reporter
        @reporter ||= case options[:format]
                      when 'text'
                        self
                      when 'markdown'
                        Polytrix::CLI::Reporters::MarkdownReporter.new
                      when 'json'
                        Polytrix::CLI::Reporters::JSONReporter.new
                      when 'yaml'
                        Polytrix::CLI::Reporters::YAMLReporter.new
                      else
                        fail "Unknown report format #{options[:format]}"
                      end
      end

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
