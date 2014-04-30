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

  class ChallengeRunner
    include Polytrix::Core::FileFinder

    def self.createRunner
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

    def interactive?
      ENV['INTERACTIVE']
    end

    def show_output?
      ENV['SHOW_OUTPUT']
    end

    def run_command(command)
      if interactive? # allows use of pry, code.interact, etc.
        system command
      else # better error messages and interrupt handling
        challenge_process = Mixlib::ShellOut.new(command)
        challenge_process.live_stream = $stdout if show_output?
        challenge_process.run_command
        challenge_process.error!
        challenge_process
      end
    end

    def setup_env_vars(vars)
      require 'fileutils'
      FileUtils.mkdir_p 'tmp'
      file = File.open("tmp/vars.#{script_extension}", 'w')
      vars.each do |key, value|
        file.puts save_environment_variable(key, value)
      end
      file.close
      file.path
    end

    def run_challenge(challenge, vars, basedir = Dir.pwd)
      middleware.call(challenge: challenge, vars: vars, basedir: basedir, challenge_runner: self)
    end

    def find_challenge!(challenge, basedir = Dir.pwd)
      find_file basedir, challenge
    rescue Polytrix::Core::FileFinder::FileNotFound
      fail FeatureNotImplementedError, challenge
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
