require 'pacto'
require 'pacto/rspec'
require 'pacto_server'
require 'goliath/test_helper'

def pacto_port
  @pacto_port ||= 9900 + ENV['TEST_ENV_NUMBER'].to_i
end

PACTO_SERVER = "http://identity.api.rackspacecloud.dev:#{pacto_port}" unless ENV['NO_PACTO']

RSpec.configure do |c|
  c.include Goliath::TestHelper
  c.before(:each)  { Pacto.clear! }
end

def with_pacto
  puts "Starting Pacto on port #{pacto_port}"
  with_api(PactoServer, {
    :stdout => true,
    :log_file => 'pacto.log',
    :config => 'pacto/config/pacto_server.rb',
    :live => true,
    # :generate => true,
    :verbose => true,
    :validate => true,
    :directory => File.join(Dir.pwd, 'pacto', 'contracts'),
    :port => pacto_port
  }) do
    yield
  end
end
