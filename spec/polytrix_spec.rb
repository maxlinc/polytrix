require 'spec_helper'

describe Polytrix do
  describe '.find_implementor' do
    it 'returns nil if no implementor is found for the file' do
      tempfile = Tempfile.new(['foo', '.java'])
      expect(described_class.find_implementor tempfile.path).to be_nil
    end

    it 'finds implementors from polytrix.yml in parent directories' do
      sample_file = 'samples/sdks/custom/challenges/HelloWorld.custom'
      implementor = described_class.find_implementor sample_file
      expect(implementor).to be_an_instance_of Polytrix::Implementor
      expect(implementor.name).to eq('My Custom project')
    end

    it 'finds implementors from by matching basedir to an already loaded implementor' do
      Polytrix.configuration.implementor(
        name: 'java',
        basedir: 'samples/sdks/java'
      )

      sample_file = 'samples/sdks/java/challenges/HelloWorld.java'
      implementor = described_class.find_implementor sample_file
      expect(implementor).to be_an_instance_of Polytrix::Implementor
      expect(implementor.name).to eq('java')
    end
  end

  describe '.validate' do
    context 'block given' do
      it 'creates and registers a validator' do
        Polytrix.validate suite: 'test', sample: 'test' do |challenge|
          # Validate the challenge results
        end
      end
    end
  end
end
