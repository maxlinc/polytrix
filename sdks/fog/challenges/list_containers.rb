#!/usr/bin/env ruby
require 'fog'

service = Fog::Storage.new({
    :provider             => 'rackspace',
    :rackspace_username   => ENV['RAX_USERNAME'],
    :rackspace_api_key    => ENV['RAX_API_KEY'],
    :rackspace_auth_url   => "#{ENV['RAX_AUTH_URL']}/v2.0"
})
containers = service.get_containers
