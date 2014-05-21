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
    # The {Polytrix::Manifest} that describes the test scenarios known to Polytrix.
    def manifest
      configuration.test_manifest
    end

    def implementors
      configuration.implementors
    end
    # The set of {Polytrix::Implementor}s registered with Polytrix.
    attr_accessor :implementors

    # Invokes the bootstrap  action for each SDK.
    # @see Polytrix::Implementor#bootstrap
    def bootstrap
      implementors.each do |implementor|
        implementor.bootstrap
      end
    end

    # Runs all of the tests described in the {manifest}
    def run_tests
      Polytrix::RSpec.run_manifest(@manifest)
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
        merged_results.deep_merge! YAML::load(File.read(result_file))
      end
      YAML::dump(merged_results.to_hash)
    end
  end
end
