#!/usr/bin/env ruby

# This example demonstrates creating a server with the Rackpace Open Cloud

require 'pacto'
require 'fog'
require './pacto_helper'

service = Fog::Compute.new({
    :provider             => 'rackspace',
    :rackspace_username   => ENV['RAX_USERNAME'],
    :rackspace_api_key    => ENV['RAX_API_KEY'],
    :rackspace_region => ENV['RACKSPACE_REGION']
})

puts "Authenticated"
