require 'spec_helper'
require 'yaml'

data = YAML::load(File.read('pacto/rackspace_uri_map.yaml'))
data['services'].each do |service_group_name, service_group|
  describe service_group_name do
    services = service_group['services'] || []
    services.each do |service_name, service|
      validate_challenge service_name, '', standard_env_vars, [] do
      end
    end
  end
end

