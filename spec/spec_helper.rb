require 'pacto'

SDKs = Dir['sdks/*'].map{|sdk| File.basename sdk}

RSpec.configure do |c|
  c.treat_symbols_as_metadata_keys_with_true_values = true
end

def invoke_challenge sdk, challenge
  sdk_dir = "sdks/#{sdk}"
  pending "#{sdk} is not setup" unless File.directory? sdk_dir
  Bundler.with_clean_env do
    Dir.chdir sdk_dir do
      challenge_script = Dir["challenges/#{challenge}.*"].first
      pending "Challenge #{challenge} is not implemented" if challenge_script.nil?
      "bootstrap failed"
      if File.exists? "scripts/wrapper"
        system "scripts/wrapper #{challenge_script}"
      else
        system "./#{challenge_script}"
      end
    end
  end
end
