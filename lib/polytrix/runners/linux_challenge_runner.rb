module Polytrix
  module Runners
    class LinuxChallengeRunner < ChallengeRunner
      include Polytrix::Core::FileSystemHelper

      def script_extension
        'sh'
      end

      def challenge_command(env_file, challenge_script, basedir = Dir.pwd)
        challenge_script = "./#{challenge_script}" unless challenge_script.to_s.start_with? '/'

        [wrapper_script(basedir), challenge_script].compact.join(' ')
      end

      def save_environment_variable(key, value)
        "export #{key}=\"#{value}\""
      end

      protected

      def wrapper_script(basedir)
        basedir_relative_wrapper = File.expand_path('scripts/wrapper', basedir)
        root_relative_wrapper = File.expand_path('scripts/wrapper', Dir.pwd)

        if File.exists? basedir_relative_wrapper
          relativize(basedir_relative_wrapper, basedir).to_s
        elsif File.exists? root_relative_wrapper
          relativize(root_relative_wrapper, basedir).to_s
        else
          nil
        end
      end
    end
  end
end
