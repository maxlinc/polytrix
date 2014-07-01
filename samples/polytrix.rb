require 'polytrix'

basedir = File.expand_path('..', __FILE__)

Polytrix.configure do |polytrix|
  Dir["#{basedir}/sdks/*"].each do |sdk|
    name = File.basename(sdk)
    polytrix.implementor name: name, basedir: sdk
  end
end

RSpec.configure do |c|
  c.expose_current_running_example_as :example
end

Polytrix.validate suite: 'Katas', sample: 'hello world' do |challenge|
  expect(challenge.result.stdout).to eq "Hello, world!\n"
end

Polytrix.validate suite: 'Katas', sample: 'quine' do |challenge|
  expect(challenge.result.stdout).to eq(challenge.source)
end

Polytrix.validate do |challenge|
  expect(challenge.result.exitstatus).to eq(0)
  expect(challenge.result.stderr).to be_empty
  expect(challenge.result.stdout).to end_with "\n"
end
