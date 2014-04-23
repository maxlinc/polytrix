require 'middleware'
require 'logger'

module Polytrix
  # Autoload pool
  module Runners
    module Middleware
      autoload :FeatureExecutor, 'polytrix/runners/middleware/feature_executor'
      autoload :ChangeDirectory, 'polytrix/runners/middleware/change_directory'
    end
  end

  class Configuration
    attr_accessor :logger
    attr_accessor :middleware

    STANDARD_MIDDLEWARE = Middleware::Builder.new do
      use Polytrix::Runners::Middleware::ChangeDirectory
      use Polytrix::Runners::Middleware::FeatureExecutor
    end

    def initialize
      @logger = Logger.new $stdout
      @middleware = STANDARD_MIDDLEWARE
    end
  end
end
