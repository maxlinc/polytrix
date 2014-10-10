require 'polytrix'
require 'bundler/gem_tasks'
require 'rake/notes/rake_task'
require 'rspec/core/rake_task'
require 'cucumber'
require 'cucumber/rake/task'
require 'rubocop/rake_task'

task :default => [:spec, :features, :self, :rubocop]

RSpec::Core::RakeTask.new('spec') do |t|
  t.rspec_opts = "-f documentation"
end

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --require features/support --require features/step_definitions -t ~@wip"
end

desc 'Remove reports and other generated artifacts'
task :clean do
  FileUtils.rm_rf 'docs'
  FileUtils.rm_rf 'reports'
end

desc 'Self-test and self-document'
task :self do
  sh 'bundle exec polytrix bootstrap'
  Dir.chdir 'samples' do
    # sh 'bundle exec polytrix test'
    sh 'bundle exec polytrix report code2doc java --destination=docs/samples/code2doc/java'
    sh 'bundle exec polytrix report code2doc python --destination=docs/samples/code2doc/python'
    sh 'bundle exec polytrix report code2doc ruby --destination=docs/samples/code2doc/ruby'
    # sh 'bundle exec polytrix code2doc samples/*.rb'
  end
end

Rubocop::RakeTask.new(:rubocop) do |task|
  # abort rake on failure
  task.fail_on_error = true
end
