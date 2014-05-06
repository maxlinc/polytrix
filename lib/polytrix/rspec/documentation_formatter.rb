require 'polytrix/rspec'
require 'hashie/mash'
require 'yaml'

module Polytrix
  module RSpec
    class DocumentationFormatter < ::RSpec::Core::Formatters::BaseFormatter
      def initialize(output)
        @results = Hashie::Mash.new
        super
      end

      def process_example(example)
        group_names = example.example_group.parent_groups.map{|g| g.description}
        group_names.inject(@results, :initializing_reader)[example.description] = {
          :results => example.execution_result,
          :source => 'file:///blah',
          :env => {
            'ABC' => 'DEF',
            'DEF' => 'GHI'
          }
        }
        doc_gen = Polytrix::DocumentationGenerator.new 'doc-src'
        doc = doc_gen.process(example.example_group.description)
        File.open("docs/#{example_group.description}.md", 'wb') do |f|
          f.write doc
        end
      end

      def dump_summary(duration, example_count, failure_count, pending_count)
        @output.puts YAML::dump(Polytrix.results.results.to_hash)
      end

      alias_method :example_passed, :process_example
      alias_method :example_pending, :process_example
      alias_method :example_failed, :process_example
    end
  end
end