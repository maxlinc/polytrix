require 'rspec/core/rake_task'
require 'pacto/rake_task'
require 'highline/import'
require 'json'

NOT_SETUP = "You need to set RAX_USERNAME and RAX_API_KEY env vars in order to run tests"

RSpec::Core::RakeTask.new('spec')
task :default => [:bootstrap, :spec]

desc 'Run all the SDK tests'
task :spec => [:check_setup]

desc 'Check pre-requisites'
task :check_setup do
  fail NOT_SETUP unless ENV['RAX_USERNAME'] && ENV['RAX_API_KEY']
end

desc 'Fetch dependencies for each SDK'
task :bootstrap do
  Bundler.with_clean_env do
    Dir['sdks/*'].each do |sdk_dir|
      Dir.chdir sdk_dir do
        if is_windows?
          system "PowerShell -NoProfile -ExecutionPolicy Bypass .\\scripts\\bootstrap"
        else
          system "scripts/bootstrap"
        end
      end
    end
  end
end

desc 'Configure the test framework'
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

desc 'Generate docco annoted source code'
task :docco do
  # FIXME: This should probably be OS-agnostic ruby...
  # Possible layouts: -l linear; -l parallel; -l classic
  system "for sdk in `ls sdks/`; do find sdks/$sdk/challenges -type f | xargs /Users/Thoughtworker/repos/opensource/docco/bin/docco -l parallel -o docs/$sdk; done"
end

task :dashboard => :docco do
  require 'formatter/feature_matrix_dashboard'
  require 'fileutils'
  formatter = Formatter::FeatureMatrixDashboard.new 'reports'
  formatter.merge_results
  # puts MultiJson.encode formatter.matrix
  matrix = formatter.html5_matrix
  FileUtils.cp_r 'spec/formatter/resources', 'docs/resources'
  File.open("docs/dashboard.html", 'w') {|f| f.write(matrix) }
end

desc "Run the tests in parallel, split by SDK.  Doesn't work on Windows, but you can use rspec_parallel to split by file instead."
task :parallel_spec do
  tags = Dir['sdks/*'].map{|sdk| File.basename sdk}
  puts "Detected SDKs: #{tags}"
  threads = []
  Thread.main[:results] = []
  tags.each_with_index do | tag, index |
    threads << Thread.new do
      puts "Starting #{tag} on process #{index}"
      Thread.main[:results] << {
        :tag => tag,
        :success  => sh("TEST_ENV_NUMBER=#{index} bundle exec rspec --options .rspec_parallel -t #{tag} spec")
      }
    end
  end
  threads.each do |thread|
    thread.join
  end
end

namespace :image do
  desc 'Build a Rackspace image (using Packer)'
  task :rackspace do
    system "cd packer; packer build -var-file=../.packer-creds.json -only openstack packer.json"
  end
end

def is_windows?
  RbConfig::CONFIG['host_os'] =~ /mswin(\d+)|mingw/i
end
