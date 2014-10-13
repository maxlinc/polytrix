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

      it 'returns a result' do
        expect(runner.run_challenge(challenge)).to be_an_instance_of Polytrix::Result
      end

      it 'calls the spy chain' do
        spies = double('Spies')
        expect(spies).to receive(:observe).with challenge
        runner.run_challenge(challenge, spies)
      end

      # Most of this belongs in the ChallengeRunner...
      xit 'finds the challenge' do
      end

      xit 'setups the env vars' do
      end

      xit 'gets the command' do
      end
    end
  end
end
