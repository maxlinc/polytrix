require 'polytrix'
begin
  require 'rspec/core'
  require 'rspec/expectations'
rescue LoadError
  raise 'polytrix/rspec requires rspec 2 or later'
end

module Polytrix
  module RSpec
    def challenge_runner
      @challenge_runner ||= begin
        @challenge_runner = Polytrix::ChallengeRunner.createRunner
        if ENV['USE_PACTO']
          require 'polytrix/runners/middleware/pacto'
          @challenge_runner.middleware.insert 0, Polytrix::Runners::Middleware::Pacto, {}
        end
        @challenge_runner
      end
    end

    def execute_challenge sdk_dir, challenge, vars
      result = challenge_runner.run_challenge challenge, vars, sdk_dir
      yield result
    end
  end
end

def feature challenge, description = "", environment = [], services = [], &block
  challenge_file = challenge.downcase.gsub(' ', '_')
  describe challenge, :markdown => description,
    # :environment => redact(environment),
    :services => services do
    Polytrix.implementors.each do |sdk|
      it sdk, sdk.to_sym => true, "data-challenge" => challenge_file, "data-sdk" => sdk do
        begin
          sdk_dir = Polytrix.sdk_dir sdk
          pending "#{sdk} is not setup" unless File.directory? sdk_dir
          challenge_runner.find_challenge! challenge_file, sdk_dir
          execute_challenge sdk_dir, challenge_file, environment do |result|
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
