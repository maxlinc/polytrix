require 'polytrix/rspec'
require 'hashie/mash'
require 'yaml'
require 'fileutils'

module Polytrix
  module RSpec
    class YAMLReport < ::RSpec::Core::Formatters::BaseFormatter
      def example_passed(example)
        add_implementation_result example, :passed
      end

      def example_failed(example)
        add_implementation_result example, :failed
      end

      def example_pending(example)
        add_implementation_result example, :pending
      end

      def dump_summary(duration, example_count, failure_count, pending_count)
        results = Hashie::Mash.new(Polytrix.manifest.dup.to_hash)
        all_challenges = examples.map { |e| e.metadata[:polytrix_challenge] }
        grouped_challenges = all_challenges.compact.group_by(&:name)
        results.suites.each do |suite_name, suite|
          suite.samples = suite.samples.each_with_object({}) do |sample_name, sample_results|
            sample_results[sample_name] ||= {}
            if grouped_challenges[sample_name]
              challenge_results = grouped_challenges[sample_name]
              challenge_results.each do |challenge|
                sample_results[sample_name][challenge.implementor.name] = challenge.result
              end
            end
          end
        end
        @output.puts YAML.dump(results.to_hash)
      end

      private

      def add_implementation_result(example, state)
        challenge = example.metadata[:polytrix_challenge]
        challenge.result.test_result = state unless challenge.nil? || challenge.result.nil?
      end
    end
  end
end
