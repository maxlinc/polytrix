require 'spec_helper'

describe Polytrix do
  describe '.validate' do
    context 'block given' do
      it 'creates and registers a validator' do
        Polytrix.validate suite: 'test', sample: 'test' do |challenge|
          # Validate the challenge results
        end
      end
    end
  end

  describe '.build_implementor' do
    context 'directory exists' do
      context 'polytrix.yml does not exist' do
        it 'builds an implementor with default settings' do
          implementor = Polytrix.build_implementor('samples/sdks/ruby')
          expect(implementor).to be_an_instance_of(Polytrix::Implementor)
          expect(implementor.name).to eq('ruby') # directory name
        end
      end

      context 'polytrix_tests.yml exists' do
        it 'loads settings from polytrix.yml' do
          implementor = Polytrix.build_implementor('samples/sdks/java')
          expect(implementor).to be_an_instance_of(Polytrix::Implementor)
          expect(implementor.name).to eq('My Java project')
        end
      end
    end
  end
end
