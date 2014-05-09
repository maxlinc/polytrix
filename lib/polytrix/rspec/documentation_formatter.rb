require 'polytrix/rspec'
require 'hashie/mash'
require 'yaml'
require 'fileutils'

module Polytrix
  module RSpec
    class DocumentationFormatter < ::RSpec::Core::Formatters::BaseFormatter
      def initialize(output)
        @results = Hashie::Mash.new
        super
      end

      def example_group_finished(example_group)
        group_names = example_group.parent_groups.map{|g| g.description}
        polytrix_challenges = example_group.examples.map { |e| e.metadata[:polytrix] }
        produce_doc example_group.description, polytrix_challenges
      end

      def dump_summary(duration, example_count, failure_count, pending_count)
        doc_gen = Polytrix::DocumentationGenerator.new 'doc-src'
        all_challenges = examples.map{|e| e.metadata[:polytrix]}
        grouped_challenges = all_challenges.compact.group_by(&:name)
        produce_doc 'index', grouped_challenges
      end

      private
      def produce_doc(name, data)
        doc_gen = Polytrix::DocumentationGenerator.new 'doc-src'
        doc = doc_gen.process(name, data)
        target_file = doc_gen.template_file.to_s.gsub 'doc-src', 'docs'
        unless target_file.empty?
          FileUtils.mkdir_p File.dirname(target_file)
          File.open(target_file, 'wb') do |f|
            f.write doc
          end
        end
      end
    end
  end
end