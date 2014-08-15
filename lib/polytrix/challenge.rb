require 'hashie/dash'
require 'hashie/extensions/coercion'
require 'hashie/extensions/indifferent_access'
require 'polytrix/documentation/helpers/code_helper'

module Polytrix
  class Challenge < Polytrix::Dash
    include Polytrix::StringHelpers
    # View helpers
    include Polytrix::Documentation::Helpers::CodeHelper

    property :name
    property :implementor
    coerce_key :implementor, Polytrix::Implementor
    property :suite, required: true
    property :vars, default: {}
    property :source_file
    coerce_key :source_file, Pathname
    property :basedir
    coerce_key :basedir, Pathname
    property :challenge_runner, default: ChallengeRunner.create_runner
    property :result
    # coerce_key :results, Array[ChallengeResult]
    property :env_file
    # coerce_key :vars, Polytrix::Manifest::Environment
    property :plugin_data, default: {}

    def slug
      slugify("#{suite}-#{name}-#{implementor.name}")
    end

    def run
      fail FeatureNotImplementedError, "Implementor #{name} has not been cloned" unless implementor.cloned?
      fail FeatureNotImplementedError, name if source_file.nil?
      fail FeatureNotImplementedError, name unless File.exists?(absolute_source_file)
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
