module Polytrix
  module Runners
    module Middleware
      describe FeatureExecutor do
        let(:app) { double('Middleware Chain') }
        let(:challenge_runner) { double('ChallengeRunner') }
        subject(:middleware) { described_class.new app }

        describe '#call' do
          let(:env) do
            {
              basedir: Pathname.new('spec/fixtures'),
              env_file: 'tmp/vars.sh',
              source_file: Pathname.new('spec/fixtures/test.js'),
              command: 'some command to execute',
              challenge_runner: challenge_runner
            }
          end

          before do
            allow(challenge_runner).to receive(:challenge_command).with(
              env[:env_file], 'spec/fixtures/test.js', 'spec/fixtures').and_return('some command to execute'
            )
            allow(challenge_runner).to receive(:run_command).with(
              'some command to execute', cwd: 'spec/fixtures').and_return Polytrix::Result.new(execution_result: 'a', source_file: 'b'
            )
            allow(app).to receive(:call).with(env)
          end

          # Most of this belongs in the ChallengeRunner...
          xit 'finds the challenge' do
          end

          xit 'setups the env vars' do
          end

          xit 'gets the command' do
          end

          it 'returns a result' do
            expect(middleware.call(env)).to be_an_instance_of Polytrix::Result
          end

          it 'continues the middleware chain' do
            expect(app).to receive(:call).with env
            middleware.call(env)
          end
        end
      end
    end
  end
end
