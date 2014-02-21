#!/usr/bin/env ruby

require 'fog'
Excon.defaults[:ssl_verify_peer] = false

service = Fog::Compute.new({
    :provider             => 'rackspace',
    :rackspace_username   => ENV['RAX_USERNAME'],
    :rackspace_api_key    => ENV['RAX_API_KEY'],
    :rackspace_region     => ENV['RAX_REGION'].downcase.to_sym,
    :rackspace_auth_url   => "#{ENV['RAX_AUTH_URL']}/v2.0"
})

server = service.servers.create :name => 'Fog Server',
                       :flavor_id => ENV['SERVER1_FLAVOR'].to_i,
                       :image_id => ENV['SERVER1_IMAGE']

puts "\n"

begin
  # Check every 5 seconds to see if server is in the active state (ready?). 
  # If the server has not been built in 5 minutes (600 seconds) an exception will be raised.
  server.wait_for(600, 5) do
    print "."
    STDOUT.flush
    ready?
  end
  
  puts "[DONE]\n\n"
  
rescue Fog::Errors::TimeoutError
  puts "[TIMEOUT]\n\n"
  
  puts "This server is currently #{server.progress}% into the build process and is taking longer to complete than expected."
  puts "You can continute to monitor the build process through the web console at https://mycloud.rackspace.com/\n\n" 
end
