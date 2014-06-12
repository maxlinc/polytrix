require 'spec_helper'

module Polytrix
  describe Implementor do
    subject(:implementor) { described_class.new(name: 'test', language: 'ruby') }
    let(:executor) { double('executor') }

    before do
      subject.executor = executor
    end

    describe '#bootstrap' do
      it 'executes script/bootstrap' do
        expect(executor).to receive(:execute).with('./scripts/bootstrap',  cwd: Pathname.new('sdks/test'))
        implementor.bootstrap
      end
    end
  end
end
