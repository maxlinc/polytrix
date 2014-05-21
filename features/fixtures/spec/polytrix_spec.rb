require 'polytrix/rspec'

Polytrix.implementors = Dir['sdks/*'].map{ |sdk|
  name = File.basename(sdk)
  Polytrix::Implementor.new :name => name
}

Polytrix.configure do |polytrix|
  polytrix.test_manifest = 'polytrix.yml'
end
Polytrix.bootstrap
Polytrix.run_tests