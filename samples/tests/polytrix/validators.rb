require 'polytrix'

Polytrix.validate 'Hello world validator', suite: 'Katas', scenario: 'hello world' do |scenario|
  expect(scenario.result.stdout).to eq "Hello, world!\n"
end

Polytrix.validate 'Quine output matches source code', suite: 'Katas', scenario: 'quine' do |scenario|
  expect(scenario.result.stdout).to eq(scenario.source)
end

Polytrix.validate 'default validator' do |scenario|
  expect(scenario.result.exitstatus).to eq(0)
  expect(scenario.result.stderr).to be_empty
  expect(scenario.result.stdout).to end_with "\n"
end
