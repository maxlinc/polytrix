require 'polytrix'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'pacto/rake_task'
require 'rake/notes/rake_task'
require 'highline/import'
require 'json'

RSpec::Core::RakeTask.new('spec') do |t|
  t.rspec_opts = "-f documentation"
end

task :default => :spec

desc 'Remove reports and other generated artifacts'
task :clean do
  FileUtils.rm_rf 'docs'
  FileUtils.rm_rf 'reports'
end
