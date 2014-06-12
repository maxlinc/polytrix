require 'polytrix/rspec'
require 'hashie/mash'
require 'yaml'
require 'fileutils'

module Polytrix
  module RSpec
    class YAMLReport < ::RSpec::Core::Formatters::BaseFormatter
      def dump_summary(duration, example_count, failure_count, pending_count)
        results = Hashie::Mash.new(Polytrix.manifest.dup.to_hash)
        all_challenges = examples.map { |e| e.metadata[:polytrix_challenge] }
        grouped_challenges = all_challenges.compact.group_by(&:name)
        results.suites.each do |suite_name, suite|
          suite.samples.each do |sample|
            if grouped_challenges[sample]
              challenge_results = grouped_challenges[sample]
              challenge_results.each do |challenge|
                suite[:results] ||= {}
                suite[:results][challenge.implementor] = challenge.result
              end
            end
          end
        end
        @output.puts YAML.dump(results.to_hash)
      end
    end
  end
end
