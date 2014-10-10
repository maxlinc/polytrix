module Polytrix
  module Executors
    module Middleware
      describe FeatureExecutor do
        let(:spies) { double('Spies') }
        let(:challenge_runner) { double('ChallengeRunner') }
        subject(:executor) { described_class.new spies }

        describe '#execute' do
          let(:challenge) do
            {
              basedir: Pathname.new('spec/fixtures'),
              vars: {},
              source_file: Pathname.new('spec/fixtures/test.js'),
              command: 'some command to execute',
              challenge_runner: challenge_runner
            }
          end

          before do
            allow(challenge_runner).to receive(:challenge_command).with(
              'spec/fixtures/test.js', 'spec/fixtures').and_return('some command to execute'
            )
            allow(challenge_runner).to receive(:env=)
            allow(challenge_runner).to receive(:run_command).with(
              'some command to execute', cwd: 'spec/fixtures').and_return Polytrix::Result.new(execution_result: 'a', source_file: 'b'
            )
            allow(spies).to receive(:observe).with(challenge)
          end

          # Most of this belongs in the ChallengeRunner...
          xit 'finds the challenge' do
          end

          xit 'setups the env vars' do
          end

          xit 'gets the command' do
          end

          it 'returns a result' do
            expect(executor.execute(challenge)).to be_an_instance_of Polytrix::Result
          end

          it 'calls the spy chain' do
            expect(spies).to receive(:observe).with challenge
            executor.execute(challenge)
          end
        end
      end
    end
  end
end
