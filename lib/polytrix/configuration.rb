require 'middleware'

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
    # Extra options for rspec
    property :rspec_options, default: ''

    def default_logger
      @default_logger ||= Logger.new(stdout: $stdout, level: env_log)
    end

    def manifest
      @manifest ||= Manifest.from_yaml 'polytrix.yml'
    end

    def manifest=(yaml_file)
      @manifest = Manifest.from_yaml yaml_file
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
