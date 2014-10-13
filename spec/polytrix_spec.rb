require 'spec_helper'

describe Polytrix do
  describe '.find_implementor' do
    before do
      Polytrix.configuration.manifest = 'samples/polytrix.yml'
    end

    it 'returns nil if no implementor is found for the file' do
      tempfile = Tempfile.new(['foo', '.java'])
      expect(described_class.find_implementor tempfile.path).to be_nil
    end

    it 'finds implementors from by matching basedir to an already loaded implementor' do
      Polytrix.manifest.implementors['java'] = Fabricate(:implementor, name: 'java', basedir: 'samples/sdks/java')
      # Polytrix.configuration.implementor(
      #   name: 'java',
      #   basedir: 'samples/sdks/java'
      # )

      sample_file = 'samples/sdks/java/challenges/HelloWorld.java'
      implementor = described_class.find_implementor sample_file
      expect(implementor).to be_an_instance_of Polytrix::Implementor
      expect(implementor.name).to eq('java')
    end
  end

  describe '.validate' do
    context 'block given' do
      it 'creates and registers a validator' do
        Polytrix.validate 'custom validator', suite: 'test', sample: 'test' do |_challenge|
          # Validate the challenge results
        end
      end
    end
  end
end
