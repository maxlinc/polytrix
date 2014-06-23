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
      it 'creates and registers Implementors' do
        # This'd be a bit nicer w/ rspec 3...
        expect do
          configuration.implementor name: 'test'
        end.to change {
          configuration.implementors
        }.from(be_empty).to be_an_instance_of(Array)

        expect(configuration.implementors.first).to be_an_instance_of Polytrix::Implementor
        expect(configuration.implementors.first.name).to eq('test')
      end
    end
  end
end
