require 'polytrix'
require 'rbconfig'

module Polytrix
  module Executors
    autoload :LinuxChallengeRunner, 'polytrix/executors/linux_challenge_executor'
    autoload :WindowsChallengeRunner, 'polytrix/executors/windows_challenge_executor'
  end

  class ChallengeRunner < Thor::Shell::Color
    include Polytrix::Util::FileSystem
    include Executor

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

    def run_challenge(challenge, spies = Polytrix::Spies)
      source_file = challenge[:source_file].to_s
      basedir = challenge[:basedir].to_s
      command = challenge_command(source_file, basedir)
      spies.observe(challenge) do
        execution_result = run_command(command, cwd: basedir, env: environment_variables(challenge[:vars]))
        challenge[:result] = Result.new(execution_result: execution_result, source_file: source_file)
      end
      challenge[:result]
    end

    protected

    def environment_variables(test_vars)
      global_vars = begin
        Polytrix.manifest[:global_env].dup
      rescue
        {}
      end
      global_vars.merge(test_vars.dup)
    end
  end
end
