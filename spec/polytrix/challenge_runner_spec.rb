module Polytrix
  describe ChallengeRunner do
    subject(:runner) { ChallengeRunner.create_runner }
    let(:implementor) { Fabricate(:implementor) }
    let(:challenge) do
      Fabricate(:challenge, name: 'factorial', source_file: 'spec/fixtures/factorial.py', basedir: 'spec/fixtures', implementor: implementor)
    end

    describe '#run_challenge' do
      it 'executes a challenge' do
        expect(runner.run_challenge challenge).to be_an_instance_of Result
      end
    end
  end
end
