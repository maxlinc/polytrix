require 'polytrix'
require 'bundler/gem_tasks'
require 'rake/notes/rake_task'
require 'rspec/core/rake_task'
require 'cucumber'
require 'cucumber/rake/task'

RSpec::Core::RakeTask.new('spec') do |t|
  t.rspec_opts = "-f documentation"
end

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --require features/support --require features/step_definitions"
end

task :default => [:spec, :features, :self]

desc 'Remove reports and other generated artifacts'
task :clean do
  FileUtils.rm_rf 'docs'
  FileUtils.rm_rf 'reports'
end

desc 'Self-test and self-document'
task :self do
  sh 'bundle exec rspec polytrix.rb -f documentation -f Polytrix::RSpec::YAMLReport -o reports/test_report.yaml -f Polytrix::RSpec::DocumentationFormatter'
end
