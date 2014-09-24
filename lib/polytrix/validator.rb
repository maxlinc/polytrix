require 'rspec/expectations'

module Polytrix
  class Validator
    include RSpec::Matchers

    UNIVERSAL_MATCHER = //
    attr_reader :description, :suite, :sample, :level, :callback

    def initialize(description, scope = {}, &validator)
      @description = description
      @suite = scope[:suite] ||= UNIVERSAL_MATCHER
      @sample = scope[:sample] ||= UNIVERSAL_MATCHER
      @callback = validator
    end

    def should_validate?(challenge)
      !!(@suite.match(challenge.suite.to_s) && @sample.match(challenge.name.to_s))
    end

    def validate(challenge)
      instance_exec challenge, &@callback if should_validate?(challenge)
    end

    def to_s
      @description
    end
  end
end
