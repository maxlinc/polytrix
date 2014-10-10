require 'polytrix'
require 'rbconfig'

module Polytrix
  module Executors
    autoload :LinuxChallengeRunner, 'polytrix/executors/linux_challenge_executor'
    autoload :WindowsChallengeRunner, 'polytrix/executors/windows_challenge_executor'
  end

  class ChallengeRunner < Thor::Shell::Color
    include Polytrix::Core::FileSystemHelper
    include Polytrix::Executors::Executor

    attr_accessor :env

    def self.create_runner
      case RbConfig::CONFIG['host_os']
      when /mswin(\d+)|mingw/i
        # TODO: Display warning that Windows support is experimental
        Executors::WindowsChallengeRunner.new
      else
        Executors::LinuxChallengeRunner.new
      end
    end

    def run_command(command, opts = { cwd: Dir.pwd })
      if Polytrix.configuration.dry_run
        puts "Would have run #{command} with #{opts.inspect}"
      else
        say_status 'polytrix:execute', command
        execute(command, opts)
      end
    end

    def run_challenge(challenge)
      FeatureExecutor.new.execute(challenge)
      challenge.result
    end
  end
end
