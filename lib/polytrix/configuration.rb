require 'middleware'
require 'rspec/support'
require 'rspec/expectations'

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

  class Configuration < Polytrix::ManifestSection
    property :dry_run,      default: false
    property :log_root,     default: '.polytrix/logs'
    property :log_level,    default: :info
    property :middleware,   default: Polytrix::Runners::Middleware::STANDARD_MIDDLEWARE
    property :implementors, default: []
    # coerce_key :implementors, Polytrix::Implementor
    property :suppress_output, default: false
    property :default_doc_template
    property :template_dir, default: "#{RESOURCES_DIR}"
    property :documentation_dir, default: 'docs/'
    property :documentation_format, default: 'md'

    # TODO: This should probably be configurable, or tied to Thor color options.
    if RSpec.respond_to?(:configuration)
      RSpec.configuration.color = true
    else
      RSpec::Expectations.configuration.color = true
    end

    def default_logger
      @default_logger ||= Logger.new(stdout: $stdout, level: env_log)
    end

    def manifest
      @manifest ||= load_manifest('polytrix.yml')
    end

    def manifest=(manifest_data)
      if manifest_data.is_a? Manifest
        @manifest = manifest_data
      else
        @manifest = Manifest.from_yaml manifest_data
      end
      @manifest
    end

    alias_method :load_manifest, :manifest=

    # The callback used to validate code samples that
    # don't have a custom validator.  The default
    # checks that the sample code runs successfully.
    def default_validator_callback
      @default_validator_callback ||= proc do |challenge|
        expect(challenge[:result].execution_result.exitstatus).to eq(0)
      end
    end

    def default_validator
      @default_validator ||= Validator.new('default validator', suite: //, scenario: //, &default_validator_callback)
    end

    attr_writer :default_validator_callback

    def register_spy(spy)
      Polytrix::Spies.register_spy(spy)
      middleware.insert 0, spy, {}
    end

    private

    # Determine the default log level from an environment variable, if it is
    # set.
    #
    # @return [Integer,nil] a log level or nil if not set
    # @api private
    def env_log
      level = ENV['POLYTRIX_LOG'] && ENV['POLYTRIX_LOG'].downcase.to_sym
      level = Polytrix::Util.to_logger_level(level) unless level.nil?
      level
    end
  end
end
