require 'spec_helper'

describe Polytrix do
  describe '.load_manifest' do
    it 'parses the YAML file' do
      expect do
        described_class.load_manifest 'spec/fixtures/polytrix.yml'
      end.to change {
        described_class.manifest
      }.from(nil).to(be_an_instance_of(Polytrix::Manifest))
    end
  end
end
