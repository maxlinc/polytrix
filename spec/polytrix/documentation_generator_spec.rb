module Polytrix
  describe DocumentationGenerator do
    let(:scenario_name) { 'Quine' }
    # let(:search_path) { 'spec/fixtures/src-doc' }
    let(:bound_data) { double }

    describe 'process' do
      let(:generated_doc) { generator.process bound_data }

      context 'when template is readable' do
        subject(:generator) { DocumentationGenerator.new('spec/fixtures/src-doc/quine.md.erb', scenario_name) }

        it 'processes the template' do
          expect(generated_doc).to include 'Examples for Quine scenario:'
        end
      end

      context 'when template is not readable' do
        subject(:generator) { DocumentationGenerator.new('non_existant_file.md', scenario_name) }
        it 'processes the template' do
          expect(generated_doc).to be_nil
        end
      end
    end

  end
end
