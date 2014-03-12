#!/usr/bin/env ruby
require 'fog'

service = Fog::Storage.new({
    :provider             => 'rackspace',
    :rackspace_username   => ENV['RAX_USERNAME'],
    :rackspace_api_key    => ENV['RAX_API_KEY'],
    :rackspace_region     => ENV['RAX_REGION'],
    :rackspace_auth_url   => "#{ENV['RAX_AUTH_URL']}/v2.0"
})
# directory = service.directories.get ENV['TEST_DIRECTORY']
# directory.files.head_object ENV['TEST_FILE']
service.head_object ENV['TEST_DIRECTORY'], ENV['TEST_FILE']
