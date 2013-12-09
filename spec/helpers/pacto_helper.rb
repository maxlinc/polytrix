require 'pacto'
require 'pacto/rspec'
require 'pacto_server'
require 'goliath/test_helper'

PACTO_SERVER = 'http://identity.api.rackspacecloud.dev:9900' unless ENV['NO_PACTO']
RSpec.configure do |c|
  c.include Goliath::TestHelper
  c.before(:each)  { Pacto.clear! }
end

def with_pacto
  with_api(PactoServer, {
    :log_file => 'pacto.log',
    :config => 'pacto/config/pacto_server.rb',
    :live => true,
    # :generate => true,
    :verbose => true,
    :validate => true,
    :directory => File.join(Dir.pwd, 'pacto', 'contracts')
  }) do
    yield
  end
end
