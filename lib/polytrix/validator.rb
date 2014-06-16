module Polytrix
  class Validator
    UNIVERSAL_MATCHER = //
    attr_reader :suite, :sample

    def initialize(scope = {}, &validator)
      @suite = scope[:suite] ||= UNIVERSAL_MATCHER
      @sample = scope[:sample] ||= UNIVERSAL_MATCHER
      @callback = validator
    end

    def should_validate?(challenge)
      !!(challenge.suite.match(@suite) && challenge.name.match(@sample))
    end

    def validate(challenge)
      @callback.call(challenge) if should_validate?(challenge)
    end
  end
end
