require 'spec_helper'

module Polytrix
  describe Result do
    describe '#status' do
      context 'mixed pass/fail' do
        let(:subject) do
          Polytrix::Result.new(
            validations: [
              { validated_by: 'max', result: 'passed' },
              { validated_by: 'polytrix', result: 'failed' }
            ]
          ).status
        end
        it 'reports the failed status' do
          is_expected.to eq('failed')
        end
      end
      context 'mix passed/pending/skipped' do
        let(:subject) do
          Polytrix::Result.new(
            validations: [
              { validated_by: 'max', result: 'passed' },
              { validated_by: 'polytrix', result: 'pending' },
              { validated_by: 'john doe', result: 'skipped' }
            ]
          ).status
        end
        it 'reports the passed status' do
          is_expected.to eq('passed')
        end
      end
      context 'mix pending/skipped' do
        let(:subject) do
          Polytrix::Result.new(
            validations: [
              { validated_by: 'max', result: 'pending' },
              { validated_by: 'polytrix', result: 'pending' },
              { validated_by: 'john doe', result: 'skipped' }
            ]
          ).status
        end
        it 'reports the pending status' do
          is_expected.to eq('pending')
        end
      end
    end
  end
end
