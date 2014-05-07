require 'simplecov'
SimpleCov.start

require 'polytrix'
require 'polytrix/rspec'

SDKs = Dir['sdks/*'].map{|sdk| File.basename sdk}

Polytrix.implementors = SDKs
