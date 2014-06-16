module Polytrix
  describe 'ValidatorRegistry' do
    subject(:registry) { Polytrix::ValidatorRegistry }

    describe '#register' do
      it 'registers a validator' do
        validator = proc do |challenge|
          expect(challenge[:result].execution_result.exitstatus).to eq(0)
        end

        expect(registry.validators).to_not include validator
        registry.register suite: 'java', sample: 'hello world', &validator
        expect(registry.validators).to include validator
      end
    end
  end
end
