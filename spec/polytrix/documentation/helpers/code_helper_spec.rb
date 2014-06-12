module Polytrix
  module Documentation
    module Helpers
      describe CodeHelper do
        let(:challenge) { Challenge.new name: 'test', source_file: @source_file }
        let(:source) do
          %q[
            # This snippet should not be in the output.
            puts "Random: #{rand}"

            # Snippet: Hello, world!
            puts 'Hello, world!'

            # Nor should this snippet
            puts 'Done'
          ]
        end
        let(:expected_snippet) do
          %q[
            puts 'Hello, world!'
          ]
        end

        around do | example |
          with_files(source: source) do | files |
            @source_file = files.first
            example.run
          end
        end

        describe '#snippet_after' do
          it 'returns the code block after the match (string)' do
            snippet = challenge.snippet_after 'Snippet: Hello, world!'
            expect(snippet.strip).to eq(expected_snippet.strip)
          end

          it 'returns the code block after the match (regex)' do
            snippet = challenge.snippet_after(/Snippet: .*/)
            expect(snippet.strip).to eq(expected_snippet.strip)
          end

          it 'returns nothing if no match is found' do
            snippet = challenge.snippet_after 'Nothing matches'
            expect(snippet).to be_empty
          end
        end

        describe '#snippet_between' do
          # Yes, whitespace doesn't work very well w/ snippet_between
          let(:expected_snippet) do
            %q[
           puts "Random: #{rand}"
# Snippet: Hello, world!
            puts 'Hello, world!'
            ]
          end

          it 'inserts all code blocks between the matching regexes' do
            snippet = challenge.snippet_between 'This snippet should not be in the output', 'Nor should this snippet'
            expect(snippet.strip).to eq(expected_snippet.strip)
          end

          it 'inserts nothing unless both matches are found' do
            # Neither match
            snippet = challenge.snippet_between 'foo', 'bar'
            expect(snippet.strip).to be_empty

            # First matches
            snippet = challenge.snippet_between 'This snippet should not be in the output', 'foo'
            expect(snippet.strip).to be_empty

            # Last matches
            snippet = challenge.snippet_between 'foo', 'Nor should this snippet'
            expect(snippet.strip).to be_empty
          end

        end

        def generate_doc_for(template_file, source_file)
          doc_gen = DocumentationGenerator.new(template_file, 'testing')
          challenge = Challenge.new name: 'test', source_file: source_file
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
