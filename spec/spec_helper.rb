require 'simplecov'
SimpleCov.start

require 'polytrix'
require 'polytrix/rspec'
require 'fabrication'

Polytrix.configure do |polytrix|
  Dir['sdks/*'].each do |sdk|
    polytrix.implementor(File.basename sdk)
  end
end

RSpec.configure do |c|
  c.before(:each) do
    Polytrix::ValidatorRegistry.clear
  end
end
