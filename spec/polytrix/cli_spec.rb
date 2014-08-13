require 'spec_helper'
require 'polytrix/cli'

module Polytrix
  describe CLI do
    let(:kernel) { double(:kernel) }
    subject { ThorSpy.on(described_class, kernel) }
    describe 'bootstrap' do
      context 'with no args' do
        it 'calls Polytrix.bootstrap' do
          expect(kernel).to receive(:exit).with(0)
          expect(Polytrix).to receive(:bootstrap)
          subject.bootstrap
        end
      end

        context 'with an existing SDK' do

        xit 'calls bootstrap on the SDK' do
          # expect(@implementor).to receive(:bootstrap)
          expect(kernel).to receive(:exit).with(0)
          expect(subject.stderr.string).to eq('')
          subject.bootstrap('test')
        end
      end

      context 'with an non-existant SDK' do
        it 'fails' do
          expect { subject.bootstrap('missing') }.to raise_error(SystemExit, 'SDK missing not found')
        end
      end
    end
  end
end
