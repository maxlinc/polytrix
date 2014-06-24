require 'spec_helper'

module Polytrix
  describe Validations do
    describe '#coerce' do
      it 'accepts an array when built via Result' do
        Polytrix::Result.new(
          validations: [
            { validated_by: 'max', result: 'passed' },
            { validated_by: 'polytrix', result: 'skipped' }
          ]
        )
      end
    end
  end
end
