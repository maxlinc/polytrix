describe 'Files' do
  file = build :file
  env = standard_env_vars.merge(
    'TEST_DIRECTORY' => file.directory.key,
    'TEST_FILE' => file.key
  )
  validate_challenge "Get object metadata", "", env, [] do
    # Will use Service nicknames or nicer URI templates in the future
    uri_pattern = /\/v1\/[\w-]+\/[\w-]+\/[\w-]+/
    expect(Pacto).to have_validated(:head, uri_pattern)
    expect(Pacto).to_not have_validated(:get, uri_pattern)
  end

  vars = standard_env_vars
  validate_challenge "List Containers", "", vars, [] do |success|
    # Assertions
    expect(Pacto).to have_validated(:get, /\/v1\/[\w-]+/) #.twice
    expect(Pacto).to_not have_failed_validations
    expect(Pacto).to_not have_unmatched_requests
  end
end
