module Polytrix
  describe Challenge do
    subject(:challenge) do
      implementor = Polytrix::Implementor.new name: 'some_sdk', basedir: 'spec/fixtures'
      implementor.build_challenge name: 'factorial', vars: {}
    end

    describe '#exec' do
      it 'executes the challenge and returns itself' do
        expect(challenge.exec).to be_an_instance_of Challenge
        expect(challenge.exec).to eq(challenge)
      end

      it 'stores the result' do
        evidence = challenge.exec
        result = evidence[:result]
        expect(result).to be_an_instance_of Result
      end
    end
  end
end
