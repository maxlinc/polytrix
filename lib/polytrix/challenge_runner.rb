require 'polytrix'
require 'mixlib/shellout'
require 'rbconfig'

module Polytrix
  module Runners
    autoload :LinuxChallengeRunner, 'polytrix/runners/linux_challenge_runner'
    autoload :WindowsChallengeRunner, 'polytrix/runners/windows_challenge_runner'
  end

  class FeatureNotImplementedError < StandardError
    def initialize(feature)
      super "Feature #{feature} is not implemented"
    end
  end

  class ChallengeRunner < Thor::Shell::Color
    include Polytrix::Core::FileSystemHelper
    include Polytrix::Executor

    def self.create_runner
      case RbConfig::CONFIG['host_os']
      when /mswin(\d+)|mingw/i
        Runners::WindowsChallengeRunner.new
      else
        Runners::LinuxChallengeRunner.new
      end
    end

    def editor_enabled?
      !challenge_editor.nil?
    end

    def challenge_editor
      ENV['CHALLENGE_EDITOR']
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
      challenge
    end

    def find_challenge!(challenge, basedir = Dir.pwd)
      find_file basedir, challenge
    rescue Polytrix::Core::FileSystemHelper::FileNotFound
      raise FeatureNotImplementedError, challenge
    end

    def edit_challenge(challenge)
      suffix = infer_suffix File.dirname(challenge)
      challenge_file = "#{challenge}#{suffix}"
      puts "Would you like to create #{challenge_file} (y/n)? "
      system "#{challenge_editor} #{challenge_file}" if $stdin.gets.strip == 'y'
      File.absolute_path challenge_file
    end

    def infer_suffix(source_dir)
      # FIXME: Should be configurable or have a better way to infer
      Dir["#{source_dir}/**/*.*"].map { |f| File.extname f }.first
    end

    private

    def middleware
      Polytrix.configuration.middleware
    end
  end
end
