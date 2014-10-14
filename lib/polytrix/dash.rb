require 'hashie/dash'
require 'hashie/extensions/coercion'

module Polytrix
  class Dash < Hashie::Dash
    include Hashie::Extensions::Coercion

    def initialize(hash = {})
      super Polytrix::Util.symbolized_hash(hash)
    end
  end
end
