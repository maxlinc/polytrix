require 'hashie/dash'
require 'hashie/extensions/coercion'
require 'hashie/extensions/indifferent_access'

module Polytrix
  class Challenge < Hashie::Dash
    include Hashie::Extensions::Coercion
    include Hashie::Extensions::IndifferentAccess
    property :name
    property :vars, :default => {}
    property :source_file
    coerce_key :source_file, Pathname
    property :basedir
    coerce_key :basedir, Pathname
    property :challenge_runner, :default => ChallengeRunner.createRunner
    property :result
    property :env_file
    coerce_key :vars, Polytrix::Manifest::Environment
    property :plugin_data, :default => {}

    def run
      challenge_runner.run_challenge self
    end

  end
end