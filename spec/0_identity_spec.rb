describe 'Identity', :markdown =>
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
    expect(Pacto).to have_validated(:post, 'https://identity.api.rackspacecloud.com/v2.0/tokens')
    expect(Pacto).to_not have_failed_validations
    expect(Pacto).to_not have_unmatched_requests
  end
end
