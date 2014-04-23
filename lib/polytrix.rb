require 'polytrix/version'
require 'polytrix/configuration'
require 'polytrix/challenge_runner'
require 'polytrix/result'
require 'polytrix/code_extractor'
require 'polytrix/output_extractor'

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
