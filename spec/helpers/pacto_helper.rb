require 'pacto'
require 'pacto/rspec'
require 'pacto/test_helper'

def pacto_port
  @pacto_port ||= 9900 + ENV['TEST_ENV_NUMBER'].to_i
end

PACTO_SERVER = "http://identity.api.rackspacecloud.dev:#{pacto_port}" unless ENV['NO_PACTO']

RSpec.configure do |c|
  c.include Pacto::TestHelper
  c.before(:each)  { Pacto.clear! }
end

def generate?
  ENV['PACTO_GENERATE'] == 'true'
end

def pacto_options
  {
    :stdout => true,
    :log_file => 'pacto.log',
    # :config => 'pacto/config/pacto_server.rb',
    :live => true,
    :generate => generate?,
    :verbose => true,
    :validate => true,
    :directory => File.join(Dir.pwd, 'pacto', 'contracts'),
    :port => pacto_port,
    :strip_dev => true,
    :strip_port => false
  }
end
