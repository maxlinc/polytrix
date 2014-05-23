module Polytrix
  describe Configuration do
    subject(:configuration) { Configuration.new }

    it 'creates a logger' do
      expect(configuration.logger).to be_kind_of Logger
    end

    describe '.test_manifest' do
      it 'parses the YAML file and registers the manifest' do
        expect do
          configuration.test_manifest = 'spec/fixtures/polytrix.yml'
        end.to change {
          configuration.test_manifest
        }.from(nil).to(be_an_instance_of(Polytrix::Manifest))
      end
    end

    describe '.implementor' do
      it 'creates and registers Implementors' do
        # This'd be a bit nicer w/ rspec 3...
        expect do
          configuration.implementor :name => 'test'
        end.to change {
          configuration.implementors
        }.from(be_empty).to be_an_instance_of(Array)

        expect(configuration.implementors.first).to be_an_instance_of Polytrix::Implementor
        expect(configuration.implementors.first.name).to eq('test')
      end
    end
  end
end
