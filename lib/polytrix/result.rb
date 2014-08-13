require 'hashie/dash'

module Polytrix
  class Result < Hashie::Dash
    extend Forwardable
    include Hashie::Extensions::Coercion

    property :execution_result # , required: true
    def_delegators :execution_result, :stdout, :stderr, :exitstatus
    property :source_file # , required: true
    property :data
    property :validations, default: Validations.new
    coerce_key :validations, Validations

    def status
      # A feature can be validated by different suites, or manually vs an automated suite.
      # That's why there's a precedence rather than boolean algebra here...
      return 'failed' if validations.any? { |v| v.result == 'failed' }
      return 'passed' if validations.any? { |v| v.result == 'passed' }
      return 'pending' if validations.any? { |v| v.result == 'pending' }
      'skipped'
    end
  end
end
