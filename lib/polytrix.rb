require 'polytrix/version'
require 'polytrix/core/file_finder'
require 'polytrix/configuration'
require 'polytrix/challenge_runner'
require 'polytrix/result'
require 'polytrix/documentation_generator'

module Polytrix
  class << self
    attr_accessor :implementors

    def configuration
      raise "configuration doesn't take a block, use configure" if block_given?
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def sdk_dir(sdk)
      "sdks/#{sdk}"
    end
  end
end
