require 'polytrix/rspec'

Polytrix.configure do |polytrix|
  polytrix.manifest = 'polytrix.yml'
end
Polytrix.bootstrap
Polytrix.load_tests
