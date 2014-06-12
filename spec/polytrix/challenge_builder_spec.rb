module Polytrix
  describe ChallengeBuilder do
    let(:implementor) { Polytrix::Implementor.new name: 'some_sdk', basedir: 'spec/fixtures' }
    subject(:builder) { described_class.new implementor }
    let(:challenge) { builder.build name: 'factorial', vars: {} }

    it 'builds a Challenge' do
      expect(challenge).to be_an_instance_of Polytrix::Challenge
    end

    it 'finds the source' do
      expected_file = Pathname.new 'spec/fixtures/factorial.py'
      expect(challenge.source_file).to eq(expected_file)
    end
  end
end
