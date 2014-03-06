describe 'Provision scalable webapp architecture', :markdown =>
  """
  This challenge will make sure you can provision all the resources used by the [reference web application architecture](http://www.rackspace.com/knowledge_center/article/rackspace-open-cloud-reference-architecture#Webapp)
  """ do
  env = standard_env_vars.merge(
    'CONTAINER_NAME' => 'sample_site',
    'TEST_DIRECTORY' => File.absolute_path(File.join(__FILE__, '../fixtures/')),
    'RAX_REGION' => 'DFW',
    'SERVER1_IMAGE' => 'f70ed7c7-b42e-4d77-83d8-40fa29825b85',
    'SERVER1_FLAVOR' => 'performance1-1'
  )
  validate_challenge "Provision scalable webapp", """
  Use the SDK to provision all the resources necessary for the webapp architecture.
  """, env, [] do |success|
    expect(Pacto).to have_validated_service('Token Service', 'Authenticate')
    expect(Pacto).to have_validated_service('Cloud Servers', 'Create Server')
    expect(Pacto).to have_validated_service('Cloud Servers', 'Get Server Details')
    # Load Balancers not available in OpenStack API reference
    # expect(Pacto).to have_validated_service('Load Balancers', 'Create')
    # expect(Pacto).to have_validated_service('Load Balancers', 'Add Node')
    expect(Pacto).to have_validated_service('Block Storage', 'Create Volume')
    expect(Pacto).to have_validated_service('Cloud Servers', 'Attach Volume')
    # Cloud Database not available in OpenStack API reference
    # expect(Pacto).to have_validated_service('Cloud Database', 'Create Instance')
    # expect(Pacto).to have_validated_service('Cloud Database', 'Create Database')
    # DNS not available in OpenStack API reference
    # expect(Pacto).to have_validated_service('DNS', 'Create Domain')
    # expect(Pacto).to have_validated_service('DNS', 'Add Records')
    # Monitoring => Telemetry in OpenStack API reference
    # expect(Pacto).to have_validated_service('Monitoring', 'TBD')
    # Backup not available in OpenStack API reference
    # expect(Pacto).to have_validated_service('Backups', 'Add Backup')
    # expect(Pacto).to have_validated_service('Backups', 'Schedule Backup')
    # Autoscale not available in OpenStack API reference
    # expect(Pacto).to have_validated_service('Autoscale', 'TBD')
  end
end
