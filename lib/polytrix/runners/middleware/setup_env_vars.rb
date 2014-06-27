require 'fileutils'

module Polytrix
  module Runners
    module Middleware
      class SetupEnvVars
        include Polytrix::Core::FileSystemHelper

        def initialize(app)
          @app   = app
        end

        def call(env)
          vars = begin
            Polytrix.manifest[:global_env].dup
          rescue
            {}
          end
          vars = vars.merge env[:vars].dup

          env[:env_file] = setup_env_vars(env[:name], vars, env[:challenge_runner])
          @app.call env
        end

        private

        def setup_env_vars(challenge_name, vars, challenge_runner)
          FileUtils.mkdir_p 'tmp'
          extension = challenge_runner.script_extension
          file = File.open(slugify("tmp/#{challenge_name}_vars.#{extension}"), 'w')
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
