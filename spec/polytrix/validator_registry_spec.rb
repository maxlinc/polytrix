module Polytrix
  describe 'ValidatorRegistry' do
    subject(:registry) { Polytrix::ValidatorRegistry }

    describe '#register' do
      it 'registers a validator' do
        callback = proc do |challenge|
          expect(challenge[:result].execution_result.exitstatus).to eq(0)
        end

        expect(registry.validators).to be_empty
        registry.register suite: 'java', sample: 'hello world', &callback
        validator = registry.validators.first
        expect(validator.suite).to eql('java')
        expect(validator.sample).to eql('hello world')
        expect(validator.instance_variable_get('@callback')).to eql(callback)
      end
    end

    describe '#validators_for' do
      let(:java_hello_world_validator) { Fabricate(:validator, suite: 'java', sample: 'hello world') }
      let(:java_validator) { Fabricate(:validator, suite: 'java', sample: //) }
      let(:ruby_validator) { Fabricate(:validator, suite: 'ruby') }

      before do
        registry.register(java_hello_world_validator)
        registry.register(java_validator)
        registry.register(ruby_validator)
      end

      it 'returns registered validators that match the scope of the challenge' do
        challenge = Fabricate(:challenge, suite: 'java', name: 'hello world')
        validators = registry.validators_for challenge
        expect(validators).to include(java_hello_world_validator, java_validator)
        expect(validators).to_not include(ruby_validator)
      end
    end
  end
end
