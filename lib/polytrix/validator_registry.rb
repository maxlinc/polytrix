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

      def register(validator, scope = {}, &callback)
        validator = Validator.new(validator, scope, &callback) if block_given?
        validators << validator
      end

      def validators_for(challenge)
        selected_validators = validators.select { |v| v.should_validate? challenge }
        selected_validators.empty? ? [Polytrix.configuration.default_validator] : selected_validators
      end

      def clear
        validators.clear
      end
    end
  end
end
