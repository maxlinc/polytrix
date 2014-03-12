#!/usr/bin/env ruby

require 'fog'
connection_opts = {
    :rackspace_username   => ENV['RAX_USERNAME'],
    :rackspace_api_key    => ENV['RAX_API_KEY'],
    :rackspace_region     => ENV['RAX_REGION'].downcase.to_sym,
    :rackspace_auth_url   => "#{ENV['RAX_AUTH_URL']}/v2.0"
}
storage = Fog::Storage.new(connection_opts.merge({:provider => 'rackspace'}))

container_name = ENV['CONTAINER_NAME']
username = ENV['RAX_USERNAME']
api_key = ENV['RAX_API_KEY']
auth_endpoint = ENV['RAX_AUTH_URL']

storage.directories.create :key => 'my-site'
