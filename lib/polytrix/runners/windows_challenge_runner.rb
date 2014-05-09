module Polytrix
  module Runners
    class WindowsChallengeRunner < ChallengeRunner
      PS_OPTIONS = '-NoProfile -ExecutionPolicy Bypass'
      def script_extension
        'ps1'
      end

      def challenge_command(env_file, challenge_script)
        # I don't know a simple powershell replacement for &&
        # See http://stackoverflow.com/questions/2416662/what-are-the-powershell-equivalent-of-bashs-and-operators
        if File.exist? 'scripts/wrapper.ps1'
          command = ". ./#{env_file}; ./scripts/wrapper.ps1 #{challenge_script}"
        else
          command = ". ./#{env_file}; ./#{challenge_script}"
        end
        "PowerShell #{PS_OPTIONS} -Command \"#{command}\""
      end

      def save_environment_variable(key, value)
        "$Env:#{key}='#{value}'"
      end
    end
  end
end
