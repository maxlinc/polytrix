require 'hashie/dash'

module Polytrix
  class Validation < Hashie::Dash
    ALLOWABLE_STATES = %w(passed pending failed skipped)
    property :validated_by, required: true
    property :result

    def result=(state)
      fail invalidate_state_error unless ALLOWABLE_STATES.include? state
      super
    end

    protected

    def invalidate_state_error(state)
      ArgumentError.new "Invalid result state: #{state}, should be one of #{ALLOWABLE_STATES.inspect}"
    end
  end
end
