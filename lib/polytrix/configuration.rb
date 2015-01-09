
require 'rspec/support'
require 'rspec/expectations'

module Polytrix
  RESOURCES_DIR = File.expand_path '../../../resources', __FILE__

  class Configuration < Polytrix::ManifestSection
    property :dry_run,      default: false
    property :log_root,     default: '.polytrix/logs'
    property :log_level,    default: :info
    property :projects, default: []
    # coerce_key :projects, Polytrix::Project

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
