module Polytrix
  module Documentation
    module Helpers
      describe CodeHelper do
        subject(:generator) { DocumentationGenerator.new('spec/fixtures/src-doc/quine.md.erb', 'testing') }
        describe '#snippet_after' do
          let(:template) {
            """
            <%= @challenges.snippet_after 'Snippet: Hello, world!' %>
            """.strip
          }
          let(:source) {
            """
            # This snippet should not be in the output.
            puts \"Random: #{rand}\"

            # Snippet: Hello, world!
            puts 'Hello, world!'

            # Nor should this snippet
            puts 'Done'
            """.strip
          }
          let(:expected_snippet) {
            """
            puts 'Hello, world!'
            """.strip
          }

          it 'inserts the code block after the matching regex' do
            with_files(:template => template, :source => source) do |template_file, source_file|
              snippet = generate_doc_for(template_file, source_file)
              expect(snippet.strip).to eq(expected_snippet)
            end
          end

          it 'inserts nothing if no match is found' do
          end
        end

        describe '#snippet_between' do

          xit 'inserts all code blocks between the matching regexes' do
          end

          xit 'inserts nothing unless both matches are found' do
          end

        end

        def generate_doc_for(template_file, source_file)
          doc_gen = DocumentationGenerator.new(template_file, 'testing')
          challenge = Challenge.new :name => 'test', :source_file => source_file
          doc_gen.process(challenge)
        end

        def with_files(files)
          tmpfiles = []
          begin
            files.each do |k, v|
              file = Tempfile.new(k.to_s)
              file.write(v)
              file.close
              tmpfiles << file
            end
            yield tmpfiles.map(&:path)
          ensure
            tmpfiles.each { |tmpfile| tmpfile.unlink }
          end
        end

      end
    end
  end
end