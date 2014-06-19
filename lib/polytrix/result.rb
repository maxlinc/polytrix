require 'hashie/dash'

module Polytrix
  class Result < Hashie::Dash
    property :execution_result #, required: true
    property :source_file #, required: true
    property :data
    property :test_result
  end
end
