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
        @challenge_runner ||= Polytrix::ChallengeRunner.createRunner
      end

      def execute_challenge(sdk_dir, challenge_name)
        implementor_name = File.basename(sdk_dir) # Might not be a good assumption
        implementor = Polytrix.implementors.find { |i| i.name == implementor_name }
        challenge = ChallengeBuilder.new(implementor).build :name => challenge_name, :basedir => sdk_dir, :implementor => implementor.name #, :vars => vars
        example.metadata[:polytrix] = challenge
        result = challenge.run
        yield result
      end
    end

    class << self
      def run_manifest(manifest)
        manifest['suites'].each do |suite_name, suite_config|
          describe suite_name do
            samples = suite_config['samples'] || []
            samples.each do |scenario|
              code_sample scenario do |result|
                instance_exec result, &Polytrix.default_validator_callback
              end
            end
          end
        end
      end
    end
  end
end

def code_sample(challenge, &block)
  describe challenge do
    Polytrix.implementors.each do |sdk|
      sdk_name = sdk.name
      sdk_dir = sdk.basedir
      it sdk_name, sdk_name.to_sym => true do
        begin
          pending "#{sdk_name} is not setup" unless File.directory? sdk_dir
          challenge_runner.find_challenge! challenge, sdk_dir
          execute_challenge sdk_dir, challenge do |result|
            instance_exec result, &block
          end
        rescue Polytrix::FeatureNotImplementedError => e
          pending e.message
        rescue ThreadError => e
          puts "ThreadError detected: #{e.message}"
          puts "ThreadError backtrace: #{e.backtrace}"
          raise e
        end
      end
    end
  end
end

RSpec.configure do |c|
  c.include Polytrix::RSpec::Helper
end