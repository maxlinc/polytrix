CHALLENGE = <<-EOS
[Create a Server](http://docs.rackspace.com/servers/api/v2/cs-devguide/content/CreateServers.html)
using the image and flavor, and region specified in the environment.
EOS

ENVIRONMENT = standard_env_vars.merge({
      'RAX_REGION' => 'DFW',
      'SERVER1_IMAGE' => 'f70ed7c7-b42e-4d77-83d8-40fa29825b85',
      'SERVER1_FLAVOR' => '2'
    })

# TBD... will load service contracts via Pacto, and automatically link to service documentation
SERVICES = []

describe 'Servers' do
  describe 'Create Server' do
    :markdown => CHALLENGE,
    "data-environment" => redact(ENVIRONMENT),
    "data-services" => SERVICES
    validate_challenge "servers", vars do |success|
      # Assertions
      expect(Pacto).to have_validated(:post, /dfw.servers.api.rackspacecloud.com\/v2\/\d+\/servers/) #.twice
      expect(Pacto).to_not have_failed_validations
      expect(Pacto).to_not have_unmatched_requests
    end
  end
end
