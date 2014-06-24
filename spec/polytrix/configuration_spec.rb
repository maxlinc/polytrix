module Polytrix
  describe Configuration do
    subject(:configuration) { Configuration.new }

    it 'creates a logger' do
      expect(configuration.logger).to be_kind_of ::Logger
    end

    describe '.test_manifest' do
      it 'parses the YAML file and registers the manifest' do
        original_manifest = configuration.test_manifest
        configuration.test_manifest = 'spec/fixtures/polytrix_tests.yml'
        new_manifest = configuration.test_manifest
        expect(original_manifest).to_not eq(new_manifest)
        expect(new_manifest).to(be_an_instance_of(Polytrix::Manifest))
      end
    end

    describe '.implementor' do
      context 'argument is a Hash' do
        it 'creates and registers Implementors' do
          # This'd be a bit nicer w/ rspec 3...
          expect do
            configuration.implementor name: 'test', basedir: '.'
          end.to change {
            configuration.implementors
          }.from(be_empty).to be_an_instance_of(Array)

          expect(configuration.implementors.first).to be_an_instance_of Polytrix::Implementor
          expect(configuration.implementors.first.name).to eq('test')
        end
      end
      context 'argument is a String' do
        context 'directory exists' do
          context 'polytrix.yml does not exist' do
            it 'builds an implementor with default settings' do
              implementor = configuration.implementor('samples/sdks/ruby')
              expect(implementor).to be_an_instance_of(Polytrix::Implementor)
              expect(implementor.name).to eq('ruby') # directory name
            end
          end

          context 'polytrix_tests.yml exists' do
            it 'loads settings from polytrix.yml' do
              implementor = configuration.implementor('samples/sdks/custom')
              expect(implementor).to be_an_instance_of(Polytrix::Implementor)
              expect(implementor.name).to eq('My Custom project')
            end
          end
        end
      end
    end
  end
end
