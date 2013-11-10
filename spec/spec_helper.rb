require 'pacto'
require 'tempfile'

SDKs = Dir['sdks/*'].map{|sdk| File.basename sdk}

RSpec.configure do |c|
  c.treat_symbols_as_metadata_keys_with_true_values = true
end

def invoke_challenge sdk, challenge, vars = standard_env_vars
  sdk_dir = "sdks/#{sdk}"
  pending "#{sdk} is not setup" unless File.directory? sdk_dir
  Bundler.with_clean_env do
    Dir.chdir sdk_dir do
      challenge_script = Dir["challenges/#{challenge}.*"].first
      pending "Challenge #{challenge} is not implemented" if challenge_script.nil?
      # Do bootstrap ahead of challenge?
      # `scripts/bootstrap`
      env_file = setup_env_vars vars
      if File.exists? "scripts/wrapper"
        system "source #{env_file} && scripts/wrapper #{challenge_script}"
      else
        system "source #{env_file} && ./#{challenge_script}"
      end
    end
  end
end

def setup_env_vars vars
  file = Tempfile.new('vars')
  vars.each do |key, value|
    file.write("export #{key}=#{value}\n")
  end
  file.close
  file.path
end

def standard_env_vars
  @standard_env_vars ||= {
    'RAX_USERNAME'   => ENV['RAX_USERNAME'],
    'RAX_API_KEY'    => ENV['RAX_API_KEY'],
    'RAX_REGION'     => 'dfw',
    'RAX_AUTH_URL'   => ENV['PACTO_SERVER'] || 'https://identity.api.rackspacecloud.com'
  }
end
