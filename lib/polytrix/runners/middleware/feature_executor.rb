module Polytrix
  module Runners
    module Middleware
      class FeatureExecutor
        include Polytrix::Core::FileSystemHelper
        def initialize(app)
          @app   = app
        end

        def call(env)
          challenge_runner = env[:challenge_runner]
          env_file = env[:env_file]
          source_file = env[:source_file].to_s
          basedir = env[:basedir].to_s
          command = challenge_runner.challenge_command(env_file, source_file, basedir)
          execution_result = challenge_runner.run_command(command, cwd: basedir)
          env[:result] = Result.new(execution_result: execution_result, source_file: source_file)
          @app.call env
          env[:result]
        end
      end
    end
  end
end
