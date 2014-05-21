module Polytrix
  describe Configuration do
    subject(:configuration) { Configuration.new }

    it 'creates a logger' do
      expect(configuration.logger).to be_kind_of Logger
    end

    describe '.test_manifest' do
      it 'parses the YAML file' do
        expect do
          configuration.test_manifest = 'spec/fixtures/polytrix.yml'
        end.to change {
          configuration.test_manifest
        }.from(nil).to(be_an_instance_of(Polytrix::Manifest))
      end
    end
  end
end
