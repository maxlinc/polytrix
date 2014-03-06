describe 'Getting Started', :markdown =>
  """
  Welcome to the SDK guide!

  In this section, you will learn how to connect to OpenStack by authenticating against the [Identity service](http://docs.openstack.org/api/openstack-identity-service/2.0/content/).

  By the end of the section, you will know:
  - You have valid, working credentials
  - You are able to load use the SDK of your choice

  In the sections that follow, we will build the cloud infrastructure for a sample application using the OpenStack services.
  """ do
  validate_challenge 'authenticate token', """
  Please use the SDK to [authenticate](http://docs.rackspace.com/auth/api/v2.0/auth-client-devguide/content/POST_authenticate_v2.0_tokens_Token_Calls.html) using a username and API key.
  """, standard_env_vars, [:Authenticate] do
    # Assertions
    expect(Pacto).to have_validated_service('Identity', 'Authenticate')
    expect(Pacto).to_not have_failed_validations
    expect(Pacto).to_not have_unmatched_requests
  end

  # validate_challenge 'all connections', """
  # Let's make a connection to each of the available OpenStack products
  # """, standard_env_vars, [] do
  #   expect(Pacto).to have_validated_service('Identity', 'Authenticate')
  #   expect(Pacto).to have_validated(:get, Addressable::Template.new('https://ord.servers.api.rackspacecloud.com/v2/{token_id}/servers/detail'))
  #   expect(Pacto).to have_validated(:get, Addressable::Template.new('https://ord.servers.api.rackspacecloud.com/v2/{token_id}/os-networksv2'))
  #   expect(Pacto).to have_validated(:get, Addressable::Template.new('https://storage101.ord1.clouddrive.com/v1/{mosso_tenant_id}/{?format}'))
  #   expect(Pacto).to have_validated(:get, Addressable::Template.new('https://ord.loadbalancers.api.rackspacecloud.com/v1.0/{token_id}/loadbalancers'))
  #   expect(Pacto).to have_validated(:get, Addressable::Template.new('https://ord.databases.api.rackspacecloud.com/v1.0/{token_id}/instances'))
  #   expect(Pacto).to have_validated(:get, Addressable::Template.new('https://dns.api.rackspacecloud.com/v1.0/{token_id}/domains'))
  #   expect(Pacto).to have_validated(:get, Addressable::Template.new('https://monitoring.api.rackspacecloud.com/v1.0/{token_id}/account'))
  #   expect(Pacto).to have_validated(:get, Addressable::Template.new('https://ord.blockstorage.api.rackspacecloud.com/v1/{token_id}/volumes'))
  #   expect(Pacto).to have_validated(:get, Addressable::Template.new('https://ord.autoscale.api.rackspacecloud.com/v1.0/{token_id}/groups'))
  #   expect(Pacto).to have_validated(:get, Addressable::Template.new('https://ord.queues.api.rackspacecloud.com/v1/{token_id}/queues'))
  #   expect(Pacto).to_not have_failed_validations
  #   expect(Pacto).to_not have_unmatched_requests
  # end
end
