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
    attr_reader :test_manifest

    property :logger,       default: Logger.new($stdout)
    property :middleware,   default: Polytrix::Runners::Middleware::STANDARD_MIDDLEWARE
    property :implementors, default: []
    # coerce_key :implementors, Polytrix::Implementor
    property :suppress_output, default: false
    property :default_doc_template

    def test_manifest=(yaml_file)
      @test_manifest = Manifest.from_yaml yaml_file
    end

    def implementor(metadata)
      implementors << Implementor.new(metadata)
    end

    # The callback used to validate code samples that
    # don't have a custom validator.  The default
    # checks that the sample code runs successfully.
    def default_validator_callback
      @default_validator_callback ||= proc do |challenge|
        expect(challenge[:result].execution_result.exitstatus).to eq(0)
      end
    end

    attr_writer :default_validator_callback
  end
end
