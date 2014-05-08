require 'fileutils'

module Polytrix
  module Runners
    module Middleware
      class SetupEnvVars
        def initialize(app)
          @app   = app
        end

        def call(env)
          challenge_runner = env[:challenge_runner]
          env[:env_file] = setup_env_vars(env[:vars], challenge_runner)
          @app.call env
        end

        private

        def setup_env_vars(vars, challenge_runner)
          FileUtils.mkdir_p 'tmp'
          file = File.open("tmp/vars.#{challenge_runner.script_extension}", 'w')
          vars.each do |key, value|
            file.puts challenge_runner.save_environment_variable(key, value)
          end
          file.close
          file.path
        end
      end
    end
  end
end
