require 'polytrix/rspec'
require 'hashie/mash'
require 'yaml'
require 'fileutils'

module Polytrix
  module RSpec
    class DocumentationFormatter < ::RSpec::Core::Formatters::BaseFormatter

      def initialize(output)
        @source_dir = 'doc-src'
        @results = Hashie::Mash.new
        @summary_files = %w(index)
        super
      end

      def example_group_finished(example_group)
        group_names = example_group.parent_groups.map{|g| g.description}
        polytrix_challenges = example_group.examples.map { |e| e.metadata[:polytrix] }
        produce_doc example_group.description, polytrix_challenges
      end

      def dump_summary(duration, example_count, failure_count, pending_count)
        all_challenges = examples.map{|e| e.metadata[:polytrix]}
        grouped_challenges = all_challenges.compact.group_by(&:name)
        @summary_files.each do |summary_file|
          produce_doc summary_file, grouped_challenges
        end
      end

      private
      def produce_doc(name, data)
        doc_gen = Polytrix::DocumentationGenerator.new @source_dir, name
        template_file = doc_gen.template_file.to_s
        suffix = template_file[template_file.index('.')..-1]
        target_file = File.join('docs', "#{name}#{suffix}")
        unless target_file.empty?
          FileUtils.mkdir_p File.dirname(target_file)
          File.open(target_file, 'wb') do |f|
            f.write doc_gen.process(data)
          end
        end
      end
    end
  end
end