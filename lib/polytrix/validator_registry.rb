require 'singleton'

module Polytrix
  class ValidatorRegistry
    include Singleton

    def validators
      @validator ||= []
    end

    class << self
      def validators
        instance.validators
      end

      def register(validator, &callback)
        if block_given?
          match_rules = validator
          validator = Validator.new(match_rules, &callback)
        end
        validators << validator
      end

      def validators_for(challenge)
        validators.select { |v| v.should_validate? challenge }
      end

      def clear
        validators.clear
      end
    end
  end
end
