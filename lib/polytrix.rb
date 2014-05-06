require 'polytrix/version'
require 'polytrix/core/result_tracker'
require 'polytrix/core/file_finder'
require 'polytrix/core/implementor'
require 'polytrix/configuration'
require 'polytrix/challenge_runner'
require 'polytrix/result'
require 'polytrix/documentation_generator'

module Polytrix
  class << self
    attr_accessor :implementors

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

    def results
      Polytrix::ResultTracker.instance
    end
  end
end
