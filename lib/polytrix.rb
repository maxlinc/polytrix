require 'polytrix/version'
require 'polytrix/executor'
require 'polytrix/manifest'
require 'polytrix/core/implementor'
require 'polytrix/core/file_finder'
require 'polytrix/challenge_runner'
require 'polytrix/challenge'
require 'polytrix/challenge_builder'
require 'polytrix/configuration'
require 'polytrix/result'
require 'polytrix/documentation_generator'

require 'polytrix/rspec'

module Polytrix
  class << self
    # The set of {Polytrix::Implementor}s registered with Polytrix.
    attr_accessor :implementors
    # The {Polytrix::Manifest} that describes the test scenarios known to Polytrix.
    attr_accessor :manifest

    # Invokes the bootstrap  action for each SDK.
    # @see Polytrix::Implementor#bootstrap
    def bootstrap
      implementors.each do |implementor|
        implementor.bootstrap
      end
    end

    # Loads the {manifest} from a YAML file.
    def load_manifest(yaml_file)
      @manifest = Polytrix::Manifest.from_yaml yaml_file
    end

    # Runs all of the tests described in the {manifest}
    def run_tests
      Polytrix::RSpec.run_manifest(@manifest)
    end

    # The callback used to validate code samples that
    # don't have a custom validator.  The default 
    # checks that the sample code runs successfully.
    def default_validator_callback
      @default_validator_callback ||= proc{ |challenge|
        expect(challenge[:result].execution_result.exitstatus).to eq(0)
      }
    end

    # Sets a new default validator to use with code
    # samples that don't have a custom validator.
    def default_validator_callback=(callback)
      @default_validator_callback = callback
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
        merged_results.deep_merge! YAML::load(File.read(result_file))
      end
      YAML::dump(merged_results.to_hash)
    end
  end
end
