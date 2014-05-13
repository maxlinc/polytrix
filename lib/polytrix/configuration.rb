require 'middleware'
require 'logger'
require 'hashie/dash'
require 'hashie/extensions/coercion'

module Polytrix
  # Autoload pool
  module Runners
    module Middleware
      autoload :FeatureExecutor, 'polytrix/runners/middleware/feature_executor'
      autoload :SetupEnvVars,    'polytrix/runners/middleware/setup_env_vars'
      autoload :ChangeDirectory, 'polytrix/runners/middleware/change_directory'

      STANDARD_MIDDLEWARE = ::Middleware::Builder.new do
        use Polytrix::Runners::Middleware::ChangeDirectory
        use Polytrix::Runners::Middleware::SetupEnvVars
        use Polytrix::Runners::Middleware::FeatureExecutor
      end
    end
  end

  class Configuration < Hashie::Dash
    include Hashie::Extensions::Coercion

    property :logger,       :default => Logger.new($stdout)
    property :middleware,   :default => Polytrix::Runners::Middleware::STANDARD_MIDDLEWARE
    property :implementors
    coerce_key :implementors, Polytrix::Implementor
    property :suppress_output, :default => false

  end
end
