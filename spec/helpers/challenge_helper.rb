require 'tempfile'

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
    'RAX_REGION'     => ENV['RAX_REGION'] || %w{DFW ORD IAD SYD HKG}.sample, # omitted LON since it requires UK account
    'RAX_AUTH_URL'   => PACTO_SERVER || 'https://identity.api.rackspacecloud.com'
  }
end

def run_challenge challenge, vars
  challenge_script = Dir.glob("challenges/#{challenge}.*", File::FNM_CASEFOLD).first
  pending "Challenge #{challenge} is not implemented" if challenge_script.nil?
  env_file = setup_env_vars vars
  if File.exists? "scripts/wrapper"
    command = ". #{env_file} && scripts/wrapper #{challenge_script}"
  else
    command = ". #{env_file} && ./#{challenge_script}"
  end
  success = system command
end
