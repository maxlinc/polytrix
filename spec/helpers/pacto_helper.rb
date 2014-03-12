require 'pacto'
require 'pacto/rspec'
require 'pacto_server'
require 'goliath/test_helper'

def pacto_port
  @pacto_port ||= 9900 + ENV['TEST_ENV_NUMBER'].to_i
end

COVERAGE_FILE = 'reports/api_coverage.yaml'
PACTO_SERVER = "http://identity.api.rackspacecloud.dev:#{pacto_port}" unless ENV['NO_PACTO']

RSpec.configure do |c|
  c.include Goliath::TestHelper
  c.before(:each)  { Pacto.clear! }
  c.after(:each) { save_coverage }
end

def generate?
  ENV['PACTO_GENERATE'] == 'true'
end

def with_pacto
  puts "Starting Pacto on port #{pacto_port}"
  with_api(PactoServer, {
    :stdout => true,
    :log_file => 'pacto.log',
    :config => 'pacto/config/pacto_server.rb',
    :live => true,
    :generate => generate?,
    :verbose => true,
    :validate => true,
    :directory => File.join(Dir.pwd, 'pacto', 'contracts'),
    :port => pacto_port
  }) do
    yield
  end
end

def save_coverage
  data = File.exists?(COVERAGE_FILE) ? YAML::load(File.read(COVERAGE_FILE)) : {}
  validations = Pacto::ValidationRegistry.instance.validations
  data[example.full_description] = validations.reject{|v| v.contract.nil?}.map{|v| v.contract.name }
  File.open(COVERAGE_FILE, 'w') {|f| f.write data.to_yaml }
end
