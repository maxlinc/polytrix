require 'yaml'
require 'polytrix'
require 'polytrix/rspec'

Polytrix.implementors = Dir['sdks/*'].map{ |sdk|
  name = File.basename(sdk)
  Polytrix::Implementor.new :name => name
}

RSpec.configure do |c|
  c.treat_symbols_as_metadata_keys_with_true_values = true
  c.include Polytrix::RSpec::Helper
end