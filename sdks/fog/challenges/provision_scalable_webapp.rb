require 'fog'

volume_name = 'my_volume'
connection_opts = {
    :rackspace_username   => ENV['RAX_USERNAME'],
    :rackspace_api_key    => ENV['RAX_API_KEY'],
    :rackspace_region     => ENV['RAX_REGION'].downcase.to_sym,
    :rackspace_auth_url   => "#{ENV['RAX_AUTH_URL']}/v2.0"
}

compute = Fog::Compute.new(connection_opts.merge(:provider => 'rackspace'))

server = compute.servers.create :name => 'Fog Server',
                       :flavor_id => ENV['SERVER1_FLAVOR'],
                       :image_id => ENV['SERVER1_IMAGE']

server.wait_for(600, 5) do
  print "."
  STDOUT.flush
  ready?
end

server = server.reload

cbs_service = Fog::Rackspace::BlockStorage.new(connection_opts)

puts "\nCreating Volume\n"
volume = cbs_service.volumes.create(:size => 100, :display_name => volume_name)
puts "\nAttaching volume\n"
attachment = server.attach_volume volume
