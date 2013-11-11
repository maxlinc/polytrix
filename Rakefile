require 'rspec/core/rake_task'

NOT_SETUP = "You need to set RAX_USERNAME and RAX_API_KEY env vars in order to run tests"

RSpec::Core::RakeTask.new('spec')
task :default => :spec

task :spec => [:check_setup, :bootstrap]

task :check_setup do
  fail NOT_SETUP unless ENV['RAX_USERNAME'] && ENV['RAX_API_KEY']
end

task :bootstrap do
  Bundler.with_clean_env do
    Dir['sdks/*'].each do |sdk_dir|
      Dir.chdir sdk_dir do
        system "scripts/bootstrap"
      end
    end
  end
end
