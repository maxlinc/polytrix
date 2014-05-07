require 'polytrix/version'
require 'polytrix/manifest'
require 'polytrix/core/result_tracker'
require 'polytrix/core/file_finder'
require 'polytrix/core/implementor'
require 'polytrix/configuration'
require 'polytrix/challenge_runner'
require 'polytrix/result'
require 'polytrix/documentation_generator'

require 'polytrix/rspec'

module Polytrix
  class << self
    attr_accessor :implementors
    attr_accessor :manifest

    def configuration
      fail "configuration doesn't take a block, use configure" if block_given?
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def sdk_dir(sdk)
      "sdks/#{sdk}"
    end

    def load_manifest(yaml_file)
      @manifest = Polytrix::Manifest.from_yaml yaml_file
    end

    def results
      Polytrix::ResultTracker.instance
    end
  end
end
