module Polytrix
  describe DocumentationGenerator do
    let(:search_path) { 'unit/polytrix/fixtures/src-doc' }
    subject(:generator) { DocumentationGenerator.new(search_path) }

    context 'when no documentation exists' do
      it 'does nothing if there is no documentation for the scenario' do
        expect(generator.process 'no_doc').to be_nil
      end
    end

    context 'when documentation does exist' do

      let(:generated_doc) { generator.process 'Quine' }

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
