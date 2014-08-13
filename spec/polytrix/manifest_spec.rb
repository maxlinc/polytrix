module Polytrix
  describe Manifest do
    describe '#from_yaml' do
      subject(:manifest) { described_class.from_yaml 'spec/fixtures/polytrix.yml' }

      it 'initializes a manifest' do
        expect(manifest).to be_an_instance_of Polytrix::Manifest
      end

      it 'processes ERB' do
        expect(manifest.global_env.LOCALE).to eq(ENV['LANG'])
      end

      it 'parses global_env' do
        expect(manifest.global_env).to be_an_instance_of Polytrix::Manifest::Environment
      end

      it 'parses suites' do
        expect(manifest.suites).to be_an_instance_of Polytrix::Manifest::Suites
      end

      describe '#find_suite' do
        before(:each) do
          Polytrix.configuration.manifest = 'samples/polytrix.yml'
        end
        it 'returns nil if no suite matches' do
          suite = subject.find_suite('none')
          expect(suite).to be_nil
        end

        it 'returns the suite if one is found' do
          suite = subject.find_suite('Katas')
          expect(suite).to be_an_instance_of Polytrix::Manifest::Suite
        end

        it 'is not case sensitive' do
          suite = subject.find_suite('katas')
          expect(suite).to be_an_instance_of Polytrix::Manifest::Suite
        end
      end

    end
  end
end
