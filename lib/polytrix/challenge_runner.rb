require 'polytrix'
require 'rbconfig'

module Polytrix
  module Runners
    autoload :LinuxChallengeRunner, 'polytrix/runners/linux_challenge_runner'
    autoload :WindowsChallengeRunner, 'polytrix/runners/windows_challenge_runner'
  end

  class ChallengeRunner < Thor::Shell::Color
    include Polytrix::Core::FileSystemHelper
    include Polytrix::Runners::Executor

    attr_accessor :env

    def self.create_runner
      case RbConfig::CONFIG['host_os']
      when /mswin(\d+)|mingw/i
        Runners::WindowsChallengeRunner.new
      else
        Runners::LinuxChallengeRunner.new
      end
    end

    def run_command(command)
      if Polytrix.configuration.dry_run
        puts "Would have run #{command}"
      else
        say_status 'polytrix:execute', command
        execute command
      end
    end

    def run_challenge(challenge)
      middleware.call(challenge)
      challenge.result
    end

    private

    def middleware
      Polytrix.configuration.middleware
    end
  end
end
