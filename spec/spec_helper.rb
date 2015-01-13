require 'simplecov'
SimpleCov.start

require 'crosstest'
require 'fabrication'
require 'thor_spy'

Crosstest.configure do |crosstest|
  Dir['sdks/*'].each do |sdk|
    crosstest.build_project sdk
  end
end

RSpec.configure do |c|
  c.before(:each) do
    Crosstest.reset
  end
  c.expose_current_running_example_as :example
end

# For Fabricators
LANGUAGES = %w(java ruby python nodejs c# golang php)
SCENARIO_NAMES = [
  'hello world',
  'quine',
  'my_kata'
]
