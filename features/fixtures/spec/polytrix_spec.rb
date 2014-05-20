require 'polytrix/rspec'

Polytrix.implementors = Dir['sdks/*'].map{ |sdk|
  name = File.basename(sdk)
  Polytrix::Implementor.new :name => name
}

Polytrix.load_manifest 'polytrix.yml'
Polytrix.bootstrap
Polytrix.run_tests