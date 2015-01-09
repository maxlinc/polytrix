require 'spec_helper'

describe Polytrix do
  describe '.validate' do
    context 'block given' do
      it 'creates and registers a validator' do
        Polytrix.validate 'custom validator', suite: 'test', scenario: 'test' do |_scenario|
          # Validate the scenario results
        end
      end
    end
  end
end
