describe 'Deploy a static website', :markdown =>
  """
  This change will make sure you can deploy a static website to Cloud Files and serve it via a CDN.
  """ do
  env = standard_env_vars.merge(
    'CONTAINER_NAME' => 'sample_site',
    'TEST_DIRECTORY' => File.absolute_path(File.join(__FILE__, '../fixtures/'))
  )

  feature "Create a Container", """
  Use the SDK to create a container to deploy the site.
  """, env, [] do |success|
    expect(Pacto).to have_validated(:put, /clouddrive\.com\/v1\/.*\/my-site\z/)
    expect(Pacto).to_not have_failed_validations
    # FIXME: Need to take care of a few more calls
    # expect(Pacto).to_not have_unmatched_requests
  end

  feature "Upload Folder", """
  Use the SDK to create a container to deploy the site.
  """, env, [] do |success|
    expect(Pacto).to have_validated(:post, /identity.api.rackspacecloud.com\/v2\.0\/tokens\z/)
    expect(Pacto).to have_validated(:put, /clouddrive\.com\/v1\/.*\/my-site\z/)
    expect(Pacto).to have_validated(:put, /clouddrive\.com\/v1\/.*\/my-site\z/)
    expect(Pacto).to have_validated(:put, /clouddrive\.com\/v1\/.*\/my-site\/index.html\z/)
    expect(Pacto).to_not have_failed_validations
    # FIXME: Need to take care of a few more calls
    # expect(Pacto).to_not have_unmatched_requests
  end

  feature "CDN Enable Container", """
  Use the SDK to create a container to deploy the site.
  """, env, [] do |success|
    expect(Pacto).to have_validated(:put, /cdn\w*.clouddrive.com\/v1\/.*\/.*\z/)
    expect(Pacto).to_not have_failed_validations
    # FIXME: Need to take care of a few more calls
    # expect(Pacto).to_not have_unmatched_requests
  end

  feature "Sync change", """
  This test will update the site with a small change.  Ideally you should upload the changed file but avoid re-uploading
  large files.
  """, env, [] do |success|
    pending
  end
end
