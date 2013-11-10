require 'pacto'

def invoke_challenge sdk, challenge
  sdk_dir = "sdks/#{sdk}"
  pending "#{sdk} is not setup" unless File.directory? sdk_dir
  Bundler.with_clean_env do
    Dir.chdir sdk_dir do
      challenge_script = Dir["challenges/#{challenge}.*"].first
      pending "Challenge #{challenge} is not implemented" if challenge_script.nil?
      # `scripts/bootstrap && bundle exec #{challenge_script}`
      system "scripts/bootstrap && bundle exec #{challenge_script}"
    end
  end
end
