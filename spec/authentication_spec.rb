describe 'Identity', :markdown =>
  """
  Tests for the Identity service
  """ do
  validate_challenge 'authenticate token', """
  Authenticate by calling the [Tokens service](http://docs.rackspace.com/auth/api/v2.0/auth-client-devguide/content/POST_authenticate_v2.0_tokens_Token_Calls.html) using
  a username and API key.
  """, standard_env_vars, [:Authenticate] do
    # Assertions
    expect(Pacto).to have_validated(:post, 'https://identity.api.rackspacecloud.com/v2.0/tokens')
    expect(Pacto).to_not have_failed_validations
    expect(Pacto).to_not have_unmatched_requests
  end
end
