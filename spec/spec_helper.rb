$:.unshift File.expand_path('../pacto', File.dirname(__FILE__))
require 'webmock/rspec'
require 'matrix_formatter'
require 'helpers/pacto_helper'
require 'helpers/challenge_helper'
require 'helpers/teardown_helper'
require 'helpers/cloudfiles_helper'

SDKs = Dir['sdks/*'].map{|sdk| File.basename sdk}

@challenge_runner = ChallengeRunnerFactory.createRunner

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
        execute_challenge sdk, challenge_file, environment do
          instance_eval &block
        end
      end
    end
  end
end

def execute_challenge sdk, challenge, vars
  sdk_dir = "sdks/#{sdk}"
  pending "#{sdk} is not setup" unless File.directory? sdk_dir
  with_pacto do
    success = false
    EM::Synchrony.defer do
      begin
        Bundler.with_clean_env do
          Dir.chdir sdk_dir do
            success = challenge_runner.run_challenge challenge, vars
            expect(success).to be_true, "#{sdk} failed to successfully execute the #{challenge} challenge"
          end
        end
      rescue ChallengeNotImplemented => e
        pending e.message
      rescue ThreadError => e
        puts "ThreadError detected: #{e.message}"
        puts "ThreadError backtrace: #{e.backtrace}"
        raise e
      end
      EM.stop
    end
    yield success
  end
end
