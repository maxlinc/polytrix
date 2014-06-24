require 'polytrix/rspec'

Polytrix.configure do |polytrix|
  Dir['sdks/*'].each do |sdk|
    polytrix.implementor sdk
  end
  polytrix.test_manifest = 'polytrix_tests.yml'
end
Polytrix.bootstrap
Polytrix.load_tests
