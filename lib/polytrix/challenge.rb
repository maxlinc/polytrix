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
    property :description
    property :implementor
    property :suite, required: true
    property :vars, default: {}
    property :source_file
    coerce_key :source_file, Pathname
    property :basedir
    coerce_key :basedir, Pathname
    property :challenge_runner, default: ChallengeRunner.create_runner
    property :result
    property :env_file
    # coerce_key :vars, Polytrix::Manifest::Environment
    property :plugin_data, default: {}

    def run
      @result = challenge_runner.run_challenge self
    end

    def absolute_source_file
      File.expand_path source_file, basedir
    end

    def validate
      run unless @result
      # validators = Polytrix::ValidatorRegistry.validators_for self
      # validators.each do |validator|
      #   validator.validate self
      # end
    end
  end
end
