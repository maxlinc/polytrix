module Polytrix
  module Core
    describe Manifest do
      describe '#from_yaml' do
        subject(:manifest) { described_class.from_yaml 'spec/fixtures/polytrix.yml' }

        it 'initializes a manifest' do
          expect(manifest).to be_an_instance_of Polytrix::Manifest
        end

        it 'processes ERB' do
          expect(manifest.global_env['LOCALE']).to eq(ENV['LANG'])
        end

        it 'parses global_env' do
          expect(manifest.global_env).to be_an_instance_of Polytrix::Manifest::Environment
        end

        it 'parses suites' do
          expect(manifest.suites).to be_an_instance_of Polytrix::Manifest::Suites
        end

      end
    end
  end
end
