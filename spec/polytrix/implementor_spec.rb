require 'spec_helper'

module Polytrix
  describe Implementor do
    subject(:implementor) { described_class.new(name: 'test', language: 'ruby', basedir: expected_sdk_dir) }
    let(:expected_sdk_dir) { 'samples/sdks/foo' }
    let(:runner) { double('runner') }
    let(:expected_sdk_path) { Pathname.new(File.absolute_path(expected_sdk_dir)) }

    before do
      subject.runner = runner
    end

    describe '#bootstrap' do
      # Need an implementor that's already cloned
      let(:expected_sdk_dir) { 'samples/sdks/ruby' }

      it 'executes script/bootstrap' do
        expect(runner).to receive(:execute_task).with('bootstrap')
        implementor.bootstrap
      end
    end

    describe '#clone' do
      it 'does nothing if there is no clone option' do
        expect(runner).to_not receive(:execute)
        implementor.clone

        implementor.clone
      end

      context 'with git as a simple string' do
        it 'clones the repo specified by the string' do
          implementor.git = 'git@github.com/foo/bar'
          expect(runner).to receive(:execute).with("git clone git@github.com/foo/bar -b master #{expected_sdk_path}")
          implementor.clone
        end
      end

      context 'with git as a hash' do
        it 'clones the repo specified by the repo parameter' do
          implementor.git = { repo: 'git@github.com/foo/bar' }
          expect(runner).to receive(:execute).with("git clone git@github.com/foo/bar -b master #{expected_sdk_path}")
          implementor.clone
        end

        it 'clones the repo on the branch specified by the brach parameter' do
          implementor.git = { repo: 'git@github.com/foo/bar', branch: 'quuz' }
          expect(runner).to receive(:execute).with("git clone git@github.com/foo/bar -b quuz #{expected_sdk_path}")
          implementor.clone
        end

        it 'clones the repo to the location specified by the to parameter' do
          implementor.git = { repo: 'git@github.com/foo/bar', to: 'sdks/foo' }
          expect(runner).to receive(:execute).with('git clone git@github.com/foo/bar -b master sdks/foo')
          implementor.clone
        end
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
