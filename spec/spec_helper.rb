$:.unshift File.expand_path('../pacto', File.dirname(__FILE__))
require 'webmock/rspec'
require 'matrix_formatter'
require 'helpers/pacto_helper'
require 'pacto/extensions/matchers'
require 'pacto/extensions/loaders/simple_loader'
require 'pacto/extensions/loaders/api_blueprint_loader'
require 'helpers/challenge_helper'
require 'helpers/teardown_helper'
require 'helpers/cloudfiles_helper'

SDKs = Dir['sdks/*'].map{|sdk| File.basename sdk}

RSpec.configure do |c|
  c.matrix_implementors = SDKs
  c.treat_symbols_as_metadata_keys_with_true_values = true
end

def challenge_runner
  @challenge_runner ||= ChallengeRunnerFactory.createRunner
end

def standard_env_vars
  challenge_runner.standard_env_vars
end

def validate_challenge challenge, description, environment, services, &block
  challenge_file = challenge.downcase.gsub(' ', '_')
  describe challenge, :markdown => description,
    :environment => redact(environment),
    :services => services do
    SDKs.each do |sdk|
      it sdk, sdk.to_sym, "data-challenge" => challenge_file, "data-sdk" => sdk do
        begin
          sdk_dir = "sdks/#{sdk}"
          pending "#{sdk} is not setup" unless File.directory? sdk_dir
          raise ChallengeNotImplemented, challenge if challenge_runner.find_challenge_file(challenge_file, sdk_dir).nil?
          execute_challenge sdk_dir, challenge_file, environment do
            instance_eval &block
          end
        rescue ChallengeNotImplemented => e
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

def execute_challenge sdk_dir, challenge, vars
  with_pacto do
    success = false
    EM::Synchrony.defer do
      Bundler.with_clean_env do
        Dir.chdir sdk_dir do
          challenge_runner.run_challenge challenge, vars
        end
      end
      EM.stop
    end
    yield success
  end
end
