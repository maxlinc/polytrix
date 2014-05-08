module Polytrix
  describe ChallengeRunner do
    subject(:runner) { ChallengeRunner.createRunner }
    let(:challenge) do
      Challenge.new :name => 'factorial', :source_file => 'spec/fixtures/factorial.py', :basedir => 'spec/fixtures'
    end

    describe '#run_challenge' do
      it 'executes a challenge' do
        expect(runner.run_challenge challenge).to be_an_instance_of Result
      end
    end
  end
end