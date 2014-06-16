require 'polytrix'
begin
  require 'rspec/core'
  require 'rspec/expectations'
  require 'rspec/core/formatters/base_text_formatter'
rescue LoadError
  raise 'polytrix/rspec requires rspec 2 or later'
end

module Polytrix
  module RSpec
    module Helper
      def challenge_runner
        @challenge_runner ||= Polytrix::ChallengeRunner.create_runner
      end

      def execute_challenge(implementor, suite, challenge_name, vars)
        challenge = implementor.build_challenge suite: suite, name: challenge_name, vars: vars
        example.metadata[:polytrix_challenge] = challenge
        result = challenge.run
        yield result
      end
    end

    class << self
      def run_manifest(manifest)
        Polytrix.manifest['suites'].each do |suite_name, suite_config|
          describe suite_name do
            samples = suite_config['samples'] || []
            samples.each do |scenario|
              vars = suite_config['env']
              code_sample scenario, vars, suite_name do |result|
                instance_exec result, &Polytrix.configuration.default_validator_callback
              end
            end
          end
        end
      end
    end
  end
end

def code_sample(challenge, vars = {}, suite = //, &block)
  describe challenge do
    Polytrix.implementors.each do |sdk|
      sdk_name = sdk.name
      sdk_dir = sdk.basedir
      it sdk_name, sdk_name.to_sym => true do
        begin
          skip "#{sdk_name} is not setup" unless File.directory? sdk_dir
          challenge_runner.find_challenge! challenge, sdk_dir
          execute_challenge sdk, suite, challenge, vars do |result|
            instance_exec result, &block
          end
        rescue Polytrix::FeatureNotImplementedError => e
          skip e.message
        rescue ThreadError => e
          puts "ThreadError detected: #{e.message}"
          puts "ThreadError backtrace: #{e.backtrace}"
          fail e
        end
      end
    end
  end
end

RSpec.configure do |c|
  c.include Polytrix::RSpec::Helper
end
