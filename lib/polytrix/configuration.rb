require 'middleware'
require 'logger'
require 'hashie/dash'
require 'hashie/extensions/coercion'

module Polytrix
  RESOURCES_DIR = File.expand_path '../../../resources', __FILE__
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

    property :dry_run,      default: false
    property :log_level,       default: 'info'
    property :middleware,   default: Polytrix::Runners::Middleware::STANDARD_MIDDLEWARE
    property :implementors, default: []
    # coerce_key :implementors, Polytrix::Implementor
    property :suppress_output, default: false
    property :default_doc_template
    property :template_dir, default: "#{RESOURCES_DIR}"
    # Extra options for rspec
    property :rspec_options, default: ''

    def logger
      @logger ||= ::Logger.new($stdout).tap do |logger|
        level = Object.const_get "::Logger::#{log_level.upcase}"
        raise "Unknown log level: #{level}" unless level
        logger.level = level
      end
    end

    def test_manifest
      @test_manifest ||= Manifest.from_yaml 'polytrix_tests.yml'
    end

    def test_manifest=(yaml_file)
      @test_manifest = Manifest.from_yaml yaml_file
    end

    def implementor(metadata)
      if metadata.is_a? Hash # load from data
        Implementor.new(metadata).tap do |implementor|
          implementors << implementor
        end
      else # load from filesystem
        folder = metadata
        fail ArgumentError, "#{folder} is not a directory" unless File.directory? folder
        settings_file = File.expand_path('polytrix.yml', folder)
        if File.exist? settings_file
          settings = YAML.load(File.read(settings_file))
          Polytrix.configuration.implementor(settings.merge(basedir: folder))
        else
          Polytrix.configuration.implementor name: File.basename(folder), basedir: folder
        end
      end
    end

    # The callback used to validate code samples that
    # don't have a custom validator.  The default
    # checks that the sample code runs successfully.
    def default_validator_callback
      @default_validator_callback ||= proc do |challenge|
        expect(challenge[:result].execution_result.exitstatus).to eq(0)
      end
    end

    def default_validator
      @default_validator ||= Validator.new(suite: //, scenario: //, &default_validator_callback)
    end

    attr_writer :default_validator_callback
  end
end
