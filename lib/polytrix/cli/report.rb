module Polytrix
  module CLI
    module Reports
      # autoload :TextReporter, 'polytrix/cli/reports/text_reporter'
      autoload :MarkdownReporter, 'polytrix/cli/reports/markdown_reporter'
      # autoload :HTMLReporter, 'polytrix/cli/reports/html_reporter'
      autoload :YAMLReporter, 'polytrix/cli/reports/yaml_reporter'
    end
    class Report < Polytrix::CLI::Base

      REPORTERS = {
        'text'     => self,
        'markdown' => Polytrix::CLI::Reports::MarkdownReporter.new,
        'yaml' => Polytrix::CLI::Reports::YAMLReporter.new,
      }

      # class_options = super.class_options
      class_option :format, desc: 'Output format for the report', default: 'text', enum: REPORTERS.keys

      desc 'report summary', 'Generate a summary report by SDK'
      config_options
      def summary
        setup
        reporter = REPORTERS[options[:format]]
        results = load_results
        table =  [%w(sdk passed failed pending skipped)]
        results.each do |sdk, summary|
          table << [sdk, summary[:passed], summary[:failed], summary[:pending], summary[:skipped]]
        end
        reporter.print_table table
      end

      protected

      def matrix_data
        @matrix ||= Hashie::Mash.new(YAML.load(Polytrix.merge_results(Dir['reports/test_report*.yaml'])))
      end

      def load_results
        result_stats = Hash.new do |hash, sdk|
          hash[sdk] = { passed: 0, failed: 0, pending: 0, skipped: 0 }
        end
        matrix_data.suites.reduce(result_stats) do |hash, (suite_name, suite)|
          suite.samples.each do |sample, suite_results|
            Polytrix.implementors.map(&:name).each do |sdk|
              result = suite_results[sdk]
              result ||= Result.new

              result.test_result ||= :skipped
              hash[sdk][result.test_result.to_sym] += 1
            end
          end
          hash
        end
        result_stats
      end
    end
  end
end
