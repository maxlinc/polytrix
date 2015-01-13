require 'spec_helper'

describe Crosstest do
  describe '.validate' do
    context 'block given' do
      it 'creates and registers a validator' do
        Crosstest.validate 'custom validator', suite: 'test', scenario: 'test' do |_scenario|
          # Validate the scenario results
        end
      end
    end
  end
end
