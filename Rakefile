require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new('spec')
task :default => :spec

task :spec => :bootstrap

task :bootstrap do
  Bundler.with_clean_env do
    Dir['sdks/*'].each do |sdk_dir|
      Dir.chdir sdk_dir do
        system "scripts/bootstrap"
      end
    end
  end
end
