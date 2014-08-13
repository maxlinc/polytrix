require 'hashie/dash'
require 'hashie/mash'
require 'hashie/extensions/coercion'

module Polytrix
  class Dash < Hashie::Dash
    include Hashie::Extensions::Coercion

    def initialize(hash = {})
      mash = Hashie::Mash.new(hash)
      super mash.to_hash(symbolize_keys: true)
    end
  end
end
