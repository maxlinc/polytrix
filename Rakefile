require 'rspec/core/rake_task'
require 'pacto/rake_task'
require 'highline/import'
require 'json'

NOT_SETUP = "You need to set RAX_USERNAME and RAX_API_KEY env vars in order to run tests"

RSpec::Core::RakeTask.new('spec')
task :default => [:bootstrap, :spec]

task :spec => [:check_setup]

task :check_setup do
  fail NOT_SETUP unless ENV['RAX_USERNAME'] && ENV['RAX_API_KEY']
end

desc 'Fetch dependencies for each SDK'
task :bootstrap do
  Bundler.with_clean_env do
    Dir['sdks/*'].each do |sdk_dir|
      Dir.chdir sdk_dir do
        system "scripts/bootstrap"
      end
    end
  end
end

task :setup do
  username = ask "Enter your Rackspace Username: "
  api_key  = ask("Enter your Rackspace API KEY: "){|q| q.echo = "*"}
  password = ask("Enter your Rackspace Password (for Packer): "){|q| q.echo = "*"}

  puts "Creating .rbenv-vars"
  File.open(".rbenv-vars", 'w') do |f|
    f.puts "RAX_USERNAME=#{username}"
    f.puts "RAX_API_KEY=#{api_key}"
    f.puts
  end

  puts "Creating .packer-creds.json"
  packer_creds = {
    "RAX_USERNAME" => username,
    "RAX_PASSWORD" => password
  }
  File.open(".packer-creds.json", "w") do |f|
    f.puts JSON.pretty_generate packer_creds
  end
end

