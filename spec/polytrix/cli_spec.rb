require 'spec_helper'
require 'polytrix/cli'

module Polytrix
  describe CLI do
    let(:kernel) { double(:kernel) }
    subject { ThorSpy.on(described_class, kernel) }
    describe 'bootstrap' do
      context 'with no args' do
        it 'calls bootstrap on each implementor' do
          expect(kernel).to receive(:exit).with(0)
          # TODO: Any way to test each implementor is called? We can't use
          # `Polytrix.implementors` because it will be reloaded.
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
          expect(kernel).to receive(:exit).with(1)
          subject.bootstrap('missing')
          expect(subject.stdout.string).to include('No SDKs matching regex `missing\'')
        end
      end
    end
  end
end
