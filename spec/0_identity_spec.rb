describe 'Getting Started', :markdown =>
  """
  Welcome to the SDK guide!

  In this section, you will learn how to connect to OpenStack by authenticating against the [Identity service](http://docs.openstack.org/api/openstack-identity-service/2.0/content/).

  By the end of the section, you will know:
  - You have valid, working credentials
  - You are able to load use the SDK of your choice

  In the sections that follow, we will build the cloud infrastructure for a sample application using the OpenStack services.
  """ do
  feature 'authenticate token', """
  Please use the SDK to [authenticate](http://docs.rackspace.com/auth/api/v2.0/auth-client-devguide/content/POST_authenticate_v2.0_tokens_Token_Calls.html) using a username and API key.
  """, standard_env_vars, [:Authenticate] do
    # Assertions
    expect(Pacto).to have_validated_service('Identity', 'Authenticate')
    expect(Pacto).to_not have_failed_validations
    expect(Pacto).to_not have_unmatched_requests
  end

  feature 'all connections', """
  Let's make a connection to each of the available OpenStack products
  """, standard_env_vars, [] do
    expect(Pacto).to have_validated_service('Identity', 'Authenticate')
    expect(Pacto).to have_validated_service('Cloud Servers', 'List Servers')
    expect(Pacto).to have_validated_service('Cloud Networks', 'List Networks')
    expect(Pacto).to have_validated_service('Cloud Files', 'List Containers')
    expect(Pacto).to have_validated_service('Cloud Load Balancers', 'List Load Balancers')
    expect(Pacto).to have_validated_service('Cloud Databases', 'List Instances')
    expect(Pacto).to have_validated_service('DNS', 'List Domains')
    # Only a few SDKs have implemented monitoring
    # expect(Pacto).to have_validated_service('Cloud Monitoring', 'Get Account')
    expect(Pacto).to have_validated_service('Cloud Block Storage', 'List Volumes')
    expect(Pacto).to have_validated_service('Autoscale', 'List Groups')
    expect(Pacto).to have_validated_service('Cloud Queues', 'List Queues')
    expect(Pacto).to_not have_failed_validations
    # expect(Pacto).to_not have_unmatched_requests
  end
end
