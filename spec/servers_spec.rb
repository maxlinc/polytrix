describe 'Servers', :markdown =>
  """
  Scenarios using [Next Generation Cloud Servers API V2](http://docs.rackspace.com/servers/api/v2/cs-devguide/content/ch_preface.html).
  """ do
    validate_challenge "Create Server", """
    [Create a Server](http://docs.rackspace.com/servers/api/v2/cs-devguide/content/CreateServers.html)
    using the image and flavor, and region specified in the environment.
    """, standard_env_vars.merge({
      'RAX_REGION' => 'DFW',
      'SERVER1_IMAGE' => 'f70ed7c7-b42e-4d77-83d8-40fa29825b85',
      'SERVER1_FLAVOR' => '2'
    }),  [] do |success|
      # Assertions
      expect(Pacto).to have_validated(:post, /dfw.servers.api.rackspacecloud.com\/v2\/\d+\/servers/) #.twice
      expect(Pacto).to_not have_failed_validations
      expect(Pacto).to_not have_unmatched_requests
  end
end
