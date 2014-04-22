require 'pacto_server'
require 'goliath/test_helper'

module Polytrix
  module Runners
    module Middleware
      class Pacto
        include Goliath::TestHelper

        def initialize(app, server_options)
          @app   = app
          # FIXM: Ideal would be to start a Pacto server once
          # @pacto_server = server(PactoServer, server_options.delete(:port) || 9901, server_options)
          # puts "Started Pacto middleware on port #{@pacto_server.port}"
        end

        def call(env)
          # FIXME: Ideal (continued) and clear the Pacto validation results before each test...
          with_pacto do
            @app.call(env)
          end
          # ...
        end

        private

        def with_pacto
          result = nil
          puts "Starting Pacto on port #{pacto_port}"
          with_api(PactoServer,
                   stdout: true,
                   log_file: 'pacto.log',
                   config: 'pacto/config/pacto_server.rb',
                   live: true,
                   generate: generate?,
                   verbose: true,
                   validate: true,
                   directory: File.join(Dir.pwd, 'pacto', 'contracts'),
                   port: pacto_port
          ) do
            EM::Synchrony.defer do
              result = yield
              EM.stop
            end
          end
          result
        end
      end
    end
  end
end
