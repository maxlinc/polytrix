module Polytrix
  describe DocumentationGenerator do
    let(:search_path) { 'spec/fixtures/src-doc' }
    let(:bound_data) { double }

    context 'when no documentation template exists for the scenario' do
      subject(:generator) { DocumentationGenerator.new(search_path, 'no_doc') }

      it 'does nothing if there is no documentation for the scenario' do
        expect(generator.process bound_data).to be_nil
      end

      context 'when the default_doc_template is set' do
        before do
          Polytrix.configure do |c|
            c.default_doc_template = 'spec/fixtures/src-doc/_scenario.md.erb'
          end
        end

        after do
          Polytrix.reset
        end

        it 'uses the default_doc_template if one is set' do
          Polytrix.configure do |c|
            c.default_doc_template = 'spec/fixtures/src-doc/_scenario.md.erb'
          end
          expect(generator.process bound_data).to eql('I am a generic template that is being used for the no_doc scenario.')
        end
      end

    end

    context 'when documentation does exist' do
      subject(:generator) { DocumentationGenerator.new(search_path, 'Quine') }
      let(:generated_doc) { generator.process bound_data }

      it 'returns the generated document as a string' do
        expect(generated_doc).to be_a(String)
      end

      context 'ERB processing' do
        it 'processes scenario' do
          expect(generated_doc).to include 'Examples for Quine scenario:'
        end

        it 'processes Polytrix.implementors' do
          fail 'This test requires implementors' unless Polytrix.implementors

          Polytrix.implementors.each do |implementor|
            expect(generated_doc).to include "## #{implementor}"
          end
        end
      end
    end
  end
end
