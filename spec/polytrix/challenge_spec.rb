module Polytrix
  describe Challenge do
    subject(:challenge) do
      implementor = Polytrix::Implementor.new :name => 'some_sdk', :basedir => 'spec/fixtures'
      builder = Polytrix::ChallengeBuilder.new implementor
      builder.build :name => 'factorial', :vars => {}
    end

    describe '#run' do
      it 'executes the challenge' do
        expect(challenge.run).to be_an_instance_of Result
      end
    end
  end
end