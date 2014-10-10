require 'simplecov'
SimpleCov.start

require 'polytrix'
require 'fabrication'
require 'thor_spy'

Polytrix.configure do |polytrix|
  Dir['sdks/*'].each do |sdk|
    polytrix.build_implementor sdk
  end
end

RSpec.configure do |c|
  c.before(:each) do
    Polytrix.reset
  end
  c.expose_current_running_example_as :example
end
