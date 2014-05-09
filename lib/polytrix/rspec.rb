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

      def execute_challenge(sdk_dir, challenge_name, vars)
        implementor_name = File.basename(sdk_dir) # Might not be a good assumption
        implementor = Polytrix.implementors.find { |i| i.name == implementor_name }
        challenge = ChallengeBuilder.new(implementor).build :name => challenge_name, :vars => vars, :basedir => sdk_dir, :implementor => implementor.name
        example.metadata[:polytrix] = challenge
        result = challenge.run
        yield result
      end
    end

    class << self
      def run_manifest(manifest)
        manifest['suites'].each do |suite_name, suite_config|
          describe suite_name do
            suite_config['samples'].each do |scenario|
              code_sample scenario, '', suite_config['env'].to_hash do |result|
                instance_exec result, &Polytrix.default_validator_callback
              end
            end
          end
        end
      end
    end
  end
end

def code_sample(challenge, description = '', environment = [], services = [], &block)
  challenge_file = challenge.downcase.gsub(' ', '_')
  describe challenge, markdown: description,
    # :environment => redact(environment),
                      services: services do
    Polytrix.implementors.each do |sdk|
      sdk = sdk.name if sdk.respond_to? :name
      it sdk, sdk.to_sym => true, 'data-challenge' => challenge_file, 'data-sdk' => sdk do
        Polytrix.results.example_started example
        begin
          sdk_dir = Polytrix.sdk_dir sdk
          pending "#{sdk} is not setup" unless File.directory? sdk_dir
          challenge_runner.find_challenge! challenge_file, sdk_dir
          execute_challenge sdk_dir, challenge_file, environment do |result|
            Polytrix.results.execution_result example, result
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