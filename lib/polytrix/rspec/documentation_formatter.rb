require 'polytrix/rspec'
require 'hashie/mash'
require 'yaml'
require 'fileutils'

module Polytrix
  module RSpec
    class DocumentationFormatter < ::RSpec::Core::Formatters::BaseFormatter
      include Polytrix::Core::FileSystemHelper

      def initialize(output)
        @templates_dir = 'doc-src'
        @output_dir = 'docs'
        @results = Hashie::Mash.new
        @summary_files = %w(index)
        super
      end

      def example_group_finished(example_group)
        polytrix_challenges = example_group.examples.map { |e| e.metadata[:polytrix_challenge] }
        target_file = target_file_for example_group
        template_file = template_for example_group
        produce_doc template_file, target_file, example_group.description, polytrix_challenges
      end

      def dump_summary(duration, example_count, failure_count, pending_count)
        all_challenges = examples.map{|e| e.metadata[:polytrix_challenge]}
        grouped_challenges = all_challenges.compact.group_by(&:name)
        @summary_files.each do |summary_file|
          template_file = template_for summary_file, :use_default => false
          next if template_file.nil?
          target_file = target_file_for_summary(summary_file)
          produce_doc template_file, summary_file, "Summary", grouped_challenges
        end
      end

      private

      def template_for(name, opts = {:use_default => true})
        name = name.description if name.respond_to? :description
        begin
          find_file @templates_dir, name, ""
        rescue Polytrix::Core::FileSystemHelper::FileNotFound
          Polytrix.configuration.default_doc_template if opts[:use_default] == true
        end
      end

      def target_file_for(example_group)
        names = [@output_dir].concat(example_group.parent_groups.reverse.map(&:description))
        # Markdown format by default, but will be overridden to match the template
        target_file = slugify(names.join File::SEPARATOR) + ".md"
      end

      def target_file_for_summary(template_file)
        name = File.basename(template_file)
        target_file = slugify("docs/#{name}")
      end

      def produce_doc(template_file, target_file, scenario, data)
        doc_gen = Polytrix::DocumentationGenerator.new template_file, scenario
        doc_gen.process data
        doc_gen.save target_file
      end
    end
  end
end