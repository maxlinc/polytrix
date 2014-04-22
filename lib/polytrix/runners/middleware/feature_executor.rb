module Polytrix
  module Runners
    module Middleware
      class FeatureExecutor

        def initialize(app)
          @app   = app
        end

        def call(env)
          challenge = env[:challenge]
          vars = env[:vars]
          challenge_runner = env[:challenge_runner]
          challenge_script = challenge_runner.find_challenge! challenge
          env_file = challenge_runner.setup_env_vars vars
          command = challenge_runner.challenge_command(env_file, challenge_script)
          process = challenge_runner.run_command command
          Result.new(:process => process, :source => challenge_script, :data => env_file)
        end
      end
    end
  end
end