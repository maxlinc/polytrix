module Polytrix
  class Validator
    UNIVERSAL_MATCHER = //
    attr_reader :suite, :sample, :callback

    def initialize(scope = {}, &validator)
      @suite = scope[:suite] ||= UNIVERSAL_MATCHER
      @sample = scope[:sample] ||= UNIVERSAL_MATCHER
      @callback = validator
    end

    def should_validate?(challenge)
      !!(@suite.match(challenge.suite) && @sample.match(challenge.name))
    end

    # def validate(challenge)
    #   instance_exec challenge, @callback if should_validate?(challenge)
    # end
  end
end
