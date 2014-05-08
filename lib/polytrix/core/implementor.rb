require 'hashie/dash'
require 'hashie/extensions/coercion'

module Polytrix
  class Implementor < Hashie::Dash
    include Hashie::Extensions::Coercion
    property :name
    property :basedir
    property :language, :default => 'ruby'
    coerce_key :basedir, Pathname

    def initialize(data)
      data[:basedir] ||= "sdks/#{data[:name]}"
      super(data)
    end
  end
end