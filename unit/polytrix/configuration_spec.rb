module Polytrix
  describe Configuration do
    subject(:configuration) { Configuration.new }

    it 'creates a logger' do
      expect(configuration.logger).to be_kind_of Logger
    end

  end
end
