require 'simplecov'
SimpleCov.start

require 'polytrix'
require 'polytrix/rspec'

Polytrix.implementors = Dir['sdks/*'].map{|sdk| File.basename sdk}
