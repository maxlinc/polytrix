module Polytrix
  class ManifestSection < Hashie::Dash
    include Hashie::Extensions::Coercion

    def initialize(hash = {})
      mash = Hashie::Mash.new(hash)
      super mash.to_hash(symbolize_keys: true)
    end
  end
end
