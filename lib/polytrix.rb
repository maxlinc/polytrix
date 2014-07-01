require 'pathname'
require 'hashie/dash'
require 'hashie/mash'
require 'hashie/extensions/coercion'
require 'polytrix/version'
require 'polytrix/logger'
require 'polytrix/core/file_system_helper'
require 'polytrix/executor'
require 'polytrix/core/implementor'
require 'polytrix/challenge_runner'
require 'polytrix/challenge'
require 'polytrix/manifest'
require 'polytrix/configuration'
require 'polytrix/validation'
require 'polytrix/validations'
require 'polytrix/result'
require 'polytrix/documentation_generator'
require 'polytrix/validator'
require 'polytrix/validator_registry'

require 'polytrix/rspec'

module Polytrix
  include Polytrix::Logger

  class << self
    include Polytrix::Core::FileSystemHelper

    def reset
      @configuration = nil
      Polytrix::ValidatorRegistry.clear
    end

    # The {Polytrix::Manifest} that describes the test scenarios known to Polytrix.
    def manifest
      configuration.test_manifest
    end

    # The set of {Polytrix::Implementor}s registered with Polytrix.
    def implementors
      configuration.implementors
    end

    def find_implementor(file)
      existing_implementor = recursive_parent_search(File.dirname(file)) do |path|
        implementors.find do |implementor|
          File.absolute_path(implementor.basedir) == File.absolute_path(path)
        end
      end
      return existing_implementor if existing_implementor

      implementor_basedir = recursive_parent_search(File.dirname(file), 'polytrix.yml')
      return Polytrix.configuration.implementor implementor_basedir if implementor_basedir

      nil
    end

    # Invokes the bootstrap  action for each SDK.
    # @see Polytrix::Implementor#bootstrap
    def bootstrap(*sdks)
      select_implementors(sdks).each do |implementor|
        implementor.bootstrap
      end
    end

    def exec(file, exec_options)
      implementor = find_implementor(file) || exec_options[:default_implementor]

      extension = File.extname(file)
      name = File.basename(file, extension)
      challenge_data = {
        name: name,
        # language: extension,
        source_file: File.expand_path(file, Dir.pwd)
      }
      challenge = implementor.build_challenge challenge_data
      challenge.run
    end

    # Registers a {Polytrix::Validator} that will be used during test
    # execution on matching {Polytrix::Challenge}s.
    def validate(scope = { suite: //, sample: // }, validator = nil, &block)
      if block_given?
        validator = Polytrix::Validator.new(scope, &block)
      elsif validator.nil?
        fail ArgumentError 'You must a block or a Validator as the second argument'
      end

      Polytrix::ValidatorRegistry.register validator
      validator
    end

    def load_tests
      Polytrix::RSpec.run_manifest(manifest)
    end

    # Runs all of the tests described in the {manifest}
    def run_tests(implementors = [])
      test_env = ENV['TEST_ENV_NUMBER'].to_i
      rspec_options = %W[--color -f documentation -f Polytrix::RSpec::YAMLReport -o reports/test_report#{test_env}.yaml]
      rspec_options.concat Polytrix.configuration.rspec_options.split if Polytrix.configuration.rspec_options
      unless implementors.empty?
        target_sdks = implementors.map(&:name)
        Polytrix.implementors.map(&:name).each do |sdk|
          # We don't have an "or" for tags, so it's easier to exclude than include multiple tags
          rspec_options.concat %W[-t ~#{sdk.to_sym}] unless target_sdks.include? sdk
        end
      end

      load_tests
      logger.info "polytrix:test\tTesting with rspec options: #{rspec_options.join ' '}"
      ::RSpec::Core::Runner.run rspec_options
      logger.info "polytrix:test\tTest execution completed"
    end

    def reset
      @configuration = nil
    end

    # @see Polytrix::Configuration
    def configuration
      fail "configuration doesn't take a block, use configure" if block_given?
      @configuration ||= Configuration.new
    end

    # @see Polytrix::Configuration
    def configure
      yield(configuration)
    end

    # Merges multiple test results files produced the rspec {Polytrix::RSpec::YAMLReport} formatter.
    # @param result_files [Array] the location of the files to merge.
    # @return [String] the merged content
    def merge_results(result_files)
      merged_results = Polytrix::Manifest.new
      result_files.each do |result_file|
        merged_results.deep_merge! YAML.load(File.read(result_file))
      end
      YAML.dump(merged_results.to_hash)
    end

    protected

    def select_implementors(sdks)
      return implementors if sdks.empty?

      sdks.map do |sdk|
        if File.directory? sdk
          sdk_dir = File.absolute_path(sdk)
          implementors.find { |i| File.absolute_path(i.basedir) == sdk_dir } || configuration.implementor(sdk_dir)
        else
          implementor = implementors.find { |i| i.name == sdk }
          fail ArgumentError, "SDK #{sdk} not found" if implementor.nil?
          implementor
        end
      end
    end
  end
end
