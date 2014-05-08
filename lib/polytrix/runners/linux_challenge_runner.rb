module Polytrix
  module Runners
    class LinuxChallengeRunner < ChallengeRunner
      def script_extension
        'sh'
      end

      def challenge_command(env_file, challenge_script)
        challenge_script = "./#{challenge_script}" unless challenge_script.to_s.start_with? '/'
        if File.exist? 'scripts/wrapper'
          ". #{env_file} && scripts/wrapper #{challenge_script}"
        else
          ". #{env_file} && #{challenge_script}"
        end
      end

      def save_environment_variable(key, value)
        "export #{key}=#{value}"
      end
    end
  end
end
