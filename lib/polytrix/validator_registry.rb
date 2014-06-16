require 'singleton'

module Polytrix
  class ValidatorRegistry
    include Singleton

    def validators
      @validator ||= []
    end

    def self.validators
      instance.validators
    end

    def self.register(match_rules, &validator)
      validators << validator
    end
  end
end
