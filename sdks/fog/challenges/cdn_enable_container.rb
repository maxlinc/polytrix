#!/usr/bin/env ruby

require 'fog'
connection_opts = {
    :rackspace_username   => ENV['RAX_USERNAME'],
    :rackspace_api_key    => ENV['RAX_API_KEY'],
    :rackspace_region     => ENV['RAX_REGION'].downcase.to_sym,
    :rackspace_auth_url   => "#{ENV['RAX_AUTH_URL']}/v2.0"
}
storage = Fog::Storage.new(connection_opts.merge({:provider => 'rackspace'}))

container_name = 'my-site'
folder_to_upload = ENV['TEST_DIRECTORY']
username = ENV['RAX_USERNAME']
api_key = ENV['RAX_API_KEY']
auth_endpoint = ENV['RAX_AUTH_URL']

directory = storage.directories.get container_name
directory.public = true
directory.save
