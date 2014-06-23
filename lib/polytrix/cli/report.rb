module Polytrix
  module CLI
    class Report < Polytrix::CLI::Base
      # class_options = super.class_options
      class_option :format, desc: 'Output format for the report', default: 'text', enum: %w(text) # soon... json yaml markdown html)

      desc 'report summary', 'Generate a summary report by SDK'
      config_options
      def summary
        setup
        results = load_results
        table =  [%w(sdk passed failed pending skipped)]
        results.each do |sdk, summary|
          table << [sdk, summary[:passed], summary[:failed], summary[:pending], summary[:skipped]]
        end
        print_table table
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
