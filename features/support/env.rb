require 'simplecov'
SimpleCov.start

require 'aruba/cucumber'
require 'aruba/jruby'

Before do
  @aruba_timeout_seconds = RUBY_PLATFORM == 'java' ? 60 : 10
end
