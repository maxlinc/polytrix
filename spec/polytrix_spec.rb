require 'spec_helper'

describe Polytrix do
  describe 'validate' do
    context 'block given' do
      it 'creates and registers a validator' do
        Polytrix.validate suite: 'test', sample: 'test' do |challenge|
          # Validate the challenge results
        end
      end
    end
  end
end
