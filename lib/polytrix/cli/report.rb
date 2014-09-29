module Polytrix
  module Reporters
    # autoload :TextReporter, 'polytrix/cli/reports/text_reporter'
    autoload :MarkdownReporter, 'polytrix/cli/reports/markdown_reporter'
    # autoload :HTMLReporter, 'polytrix/cli/reports/html_reporter'
    autoload :JSONReporter, 'polytrix/cli/reports/json_reporter'
    autoload :YAMLReporter, 'polytrix/cli/reports/yaml_reporter'
  end
  module Command
    class Report < Polytrix::CLI::Base
      # class_options = super.class_options
      class_option :format, desc: 'Output format for the report', default: 'text', enum: %w(text markdown json yaml)

      desc 'report summary', 'Generate a summary report by SDK'
      config_options
      log_options
      def summary
        setup
        results = load_results
        table =  [%w(sdk passed failed pending skipped)]
        results.each do |sdk, summary|
          table << [sdk, summary[:passed], summary[:failed], summary[:pending], summary[:skipped]]
        end
        reporter.print_table table
      end

      desc 'report matrix', 'Generate a feature matrix report'
      config_options
      log_options
      def matrix
        setup
        sdk_names = Polytrix.implementors.map(&:name)
        table = [%w(Product Feature).concat(sdk_names)]

        matrix_data.suites.each do |suite_name, suite_data|
          suite_data.samples.each do |scenario_name, scenario_results|

            statuses = sdk_names.map do |sdk|
              result = Result.new(scenario_results[sdk])
              result.status
            end

            table << [suite_name, scenario_name].concat(statuses)
          end
        end
        reporter.print_table table
      end

      protected

      def load_results
        result_stats = Hash.new do |hash, sdk|
          hash[sdk] = { passed: 0, failed: 0, pending: 0, skipped: 0 }
        end
        matrix_data.suites.reduce(result_stats) do |hash, (suite_name, suite)|
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
    end
  end
end
