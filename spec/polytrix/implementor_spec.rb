require 'spec_helper'

module Polytrix
  describe Implementor do
    subject(:implementor) { described_class.new(name: 'test', language: 'ruby', basedir: 'sdks/test') }
    let(:executor) { double('executor') }

    before do
      subject.executor = executor
    end

    describe '#bootstrap' do
      it 'executes script/bootstrap' do
        expect(executor).to receive(:execute).with('./scripts/bootstrap',  cwd: Pathname.new(File.absolute_path('sdks/test')), prefix: 'test')
        implementor.bootstrap
      end
    end

    describe '#build_challenge' do
      subject(:implementor) { Polytrix::Implementor.new name: 'some_sdk', basedir: File.absolute_path('spec/fixtures') }
      let(:challenge) { Fabricate(:challenge, name: 'factorial', vars: {}) }

      it 'builds a Challenge' do
        expect(challenge).to be_an_instance_of Polytrix::Challenge
      end

      it 'finds the source' do
        expected_file = Pathname.new 'spec/fixtures/factorial.py'
        expect(challenge.source_file).to eq(expected_file)
      end
    end
  end
end
