require 'mixlib/shellout'
require 'rbconfig'

module Polytrix
  module Runners
    autoload :LinuxChallengeRunner, 'polytrix/runners/linux_challenge_runner'
    autoload :WindowsChallengeRunner, 'polytrix/runners/windows_challenge_runner'
  end

  class FeatureNotImplementedError < StandardError
    def initialize feature
      super "Feature #{feature} is not implemented"
    end
  end

  class ChallengeRunner
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

    def run_command command
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

    def setup_env_vars vars
      require 'fileutils'
      FileUtils.mkdir_p 'tmp'
      file = File.open("tmp/vars.#{script_extension}", 'w')
      vars.each do |key, value|
        file.puts save_environment_variable(key, value)
      end
      file.close
      file.path
    end

    def run_challenge challenge, vars
      challenge_script = find_challenge! challenge
      raise FeatureNotImplementedError, challenge if challenge_script.nil?
      env_file = setup_env_vars vars
      process = run_command challenge_command(env_file, challenge_script)
      Result.new(:process => process, :source => challenge_script, :data => env_file)
    end

    def find_challenge! challenge, basedir = Dir.pwd
      challenge_file = Dir.glob("#{basedir}/challenges/#{challenge}.*", File::FNM_CASEFOLD).first ||
        Dir.glob("#{basedir}/challenges/#{challenge.gsub('_','')}.*", File::FNM_CASEFOLD).first
      challenge_file = edit_challenge("#{basedir}/challenges/#{challenge}") if challenge_file.nil? && editor_enabled?
      raise FeatureNotImplementedError, challenge if challenge_file.nil? or !File.readable?(challenge_file)
      challenge_file
    end

    def edit_challenge challenge
      suffix = infer_suffix File.dirname(challenge)
      challenge_file = "#{challenge}#{suffix}"
      puts "Would you like to create #{challenge_file} (y/n)? "
      system "#{challenge_editor} #{challenge_file}" if $stdin.gets.strip == 'y'
      File.absolute_path challenge_file
    end

    def infer_suffix source_dir
      # FIXME: Should be configurable or have a better way to infer
      Dir["#{source_dir}/**/*.*"].map{|f| File.extname f}.first
    end
  end
end