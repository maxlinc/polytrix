module Polytrix
  describe ChallengeRunner do
    subject(:runner) { ChallengeRunner.create_runner }
    let(:implementor) { double(name: 'foo') }
    let(:challenge) do
      Fabricate(:challenge, name: 'factorial', source_file: 'spec/fixtures/factorial.py', basedir: 'spec/fixtures', implementor: implementor)
    end

    describe '#run_challenge' do
      it 'executes a challenge' do
        expect(runner.run_challenge challenge).to be_an_instance_of Challenge
      end
    end
  end
end
