require 'hashie/dash'

module Polytrix
  class Validations < Set
    def to_hash
      map do |v|
        v.to_hash
      end
    end

    def to_yaml
      to_hash.to_yaml
    end

    # Hashie Coercion - automatically treat all values as Validation
    def self.coerce(obj)
      data = obj.map do |value|
        Validation.new(value)
      end
      new data
    end
  end
end
