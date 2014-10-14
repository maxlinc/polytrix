require 'rspec/expectations'

module Polytrix
  class Validator
    include RSpec::Matchers

    UNIVERSAL_MATCHER = //
    attr_reader :description, :suite, :scenario, :level, :callback

    def initialize(description, scope = {}, &validator)
      @description = description
      @suite = scope[:suite] ||= UNIVERSAL_MATCHER
      @scenario = scope[:scenario] ||= UNIVERSAL_MATCHER
      @callback = validator
    end

    def should_validate?(challenge)
      # TODO: Case-insensitive matching?
      !!(@suite.match(challenge.suite.to_s) && @scenario.match(challenge.name.to_s)) # rubocop:disable Style/DoubleNegation
    end

    def validate(challenge)
      instance_exec(challenge, &@callback) if should_validate?(challenge)
      challenge.result.validations[description] = Validation.new(result: :passed)
    rescue StandardError, RSpec::Expectations::ExpectationNotMetError => e
      validation = Validation.new(result: :failed, error: ValidationFailure.new(e.message, e))
      challenge.result.validations[description] = validation
    end

    def to_s
      @description
    end
  end
end
