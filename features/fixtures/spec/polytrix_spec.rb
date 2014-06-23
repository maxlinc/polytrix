require 'polytrix/rspec'

Polytrix.configure do |polytrix|
  Dir['sdks/*'].each do |sdk|
    name = File.basename(sdk)
    polytrix.implementor name: name
  end
  polytrix.test_manifest = 'polytrix_tests.yml'
end
Polytrix.bootstrap
Polytrix.run_tests
