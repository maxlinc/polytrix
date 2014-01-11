require 'tempfile'
require 'rbconfig'

class ChallengeNotImplemented < StandardError
  def initialize challenge
    super "Challenge #{challenge} is not implemented"
  end
end

class ChallengeRunnerFactory
  def self.createRunner
    case RbConfig::CONFIG['host_os']
    when /mswin(\d+)|mingw/i
      WindowsChallengeRunner.new
    else
      LinuxChallengeRunner.new
    end
  end
end

class ChallengeRunner
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

  def standard_env_vars
    @standard_env_vars ||= {
      'RAX_USERNAME'   => ENV['RAX_USERNAME'],
      'RAX_API_KEY'    => ENV['RAX_API_KEY'],
      'RAX_REGION'     => ENV['RAX_REGION'] || %w{DFW ORD IAD SYD HKG}.sample, # omitted LON since it requires UK account
      'RAX_AUTH_URL'   => PACTO_SERVER || 'https://identity.api.rackspacecloud.com'
    }
  end

  def run_challenge challenge, vars
    challenge_script = Dir.glob("challenges/#{challenge}.*", File::FNM_CASEFOLD).first
    raise ChallengeNotImplemented, challenge if challenge_script.nil?
    env_file = setup_env_vars vars
    system execute_challenge_command(env_file, challenge_script)
  end
end

class LinuxChallengeRunner < ChallengeRunner
  def script_extension
    "sh"
  end

  def execute_challenge_command env_file, challenge_script
    if File.exists? "scripts/wrapper"
      ". #{env_file} && scripts/wrapper #{challenge_script}"
    else
      ". #{env_file} && ./#{challenge_script}"
    end
  end

  def save_environment_variable key, value
    "export #{key}=#{value}"
  end
end

class WindowsChallengeRunner < ChallengeRunner
  PS_OPTIONS = "-NoProfile -ExecutionPolicy Bypass"
  def script_extension
    "ps1"
  end

  def execute_challenge_command env_file, challenge_script
    # I don't know a simple powershell replacement for &&
    # See http://stackoverflow.com/questions/2416662/what-are-the-powershell-equivalent-of-bashs-and-operators
    if File.exists? "scripts/wrapper.ps1"
      command = ". ./#{env_file}; ./scripts/wrapper.ps1 #{challenge_script}"
    else
      command = ". ./#env_file}; ./#{challenge_script}"
    end
    "PowerShell #{PS_OPTIONS} -Command \"#{command}\""
  end

  def save_environment_variable key, value
    "$Env:#{key}='#{value}'"
  end
end
