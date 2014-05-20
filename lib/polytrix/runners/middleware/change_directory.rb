module Polytrix
  module Runners
    module Middleware
      class ChangeDirectory
        def initialize(app)
          @app   = app
        end

        def call(env)
          sdk_dir = env[:basedir]
          Bundler.with_clean_env do
            Dir.chdir sdk_dir do
              @app.call env
            end
          end
        end
      end
    end
  end
end