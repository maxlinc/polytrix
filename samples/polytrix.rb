require 'polytrix'

Polytrix.validate 'Hello world validator', suite: 'Katas', scenario: 'hello world' do |challenge|
  expect(challenge.result.stdout).to eq "Hello, world!\n"
end

Polytrix.validate 'Quine output matches source code', suite: 'Katas', scenario: 'quine' do |challenge|
  expect(challenge.result.stdout).to eq(challenge.source)
end

Polytrix.validate 'default validator' do |challenge|
  expect(challenge.result.exitstatus).to eq(0)
  expect(challenge.result.stderr).to be_empty
  expect(challenge.result.stdout).to end_with "\n"
end
