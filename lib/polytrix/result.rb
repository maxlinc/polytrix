require 'hashie/dash'

module Polytrix
  class Result < Hashie::Dash
    property :process, required: true
    property :source
    property :data
  end
end
