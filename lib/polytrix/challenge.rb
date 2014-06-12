require 'hashie/dash'
require 'hashie/extensions/coercion'
require 'hashie/extensions/indifferent_access'
require 'polytrix/documentation/helpers/code_helper'

module Polytrix
  class Challenge < Hashie::Dash
    include Hashie::Extensions::Coercion

    # View heleprs
    include Polytrix::Documentation::Helpers::CodeHelper

    property :name
    property :implementor
    property :vars, default: {}
    property :source_file
    coerce_key :source_file, Pathname
    property :basedir
    coerce_key :basedir, Pathname
    property :challenge_runner, default: ChallengeRunner.create_runner
    property :result
    property :env_file
    coerce_key :vars, Polytrix::Manifest::Environment
    property :plugin_data, default: {}

    def run
      challenge_runner.run_challenge self
    end
  end
end
