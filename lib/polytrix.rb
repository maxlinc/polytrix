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
    attr_accessor :implementors
    attr_accessor :manifest
    attr_accessor :default_validator_callback

    def bootstrap
      implementors.each do |implementor|
        implementor.bootstrap
      end
    end

    def default_validator_callback
      @default_validator_callback ||= proc{ |challenge|
        expect(challenge[:result].process.exitstatus).to eq(0)
      }
    end

    def default_validator_callback=(callback)
      @default_validator_callback = callback
    end

    def configuration
      fail "configuration doesn't take a block, use configure" if block_given?
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def load_manifest(yaml_file)
      @manifest = Polytrix::Manifest.from_yaml yaml_file
    end

    def run_tests
      Polytrix::RSpec.run_manifest(@manifest)
    end
  end
end
