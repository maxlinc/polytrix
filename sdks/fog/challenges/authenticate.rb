#!/usr/bin/env ruby

# This example demonstrates creating a server with the Rackpace Open Cloud

require 'pacto'
require 'rubygems' #required for Ruby 1.8.x
require 'fog'
require './pacto_helper'

# WebMock.allow_net_connect!
# Pacto.configure do |config|
#   config.contracts_path = '../pacto/contracts'
# end
# Pacto.generate!

# create Next Generation Cloud Server service
service = Fog::Compute.new({
    :provider             => 'rackspace',
    :rackspace_username   => ENV['RAX_USERNAME'],
    :rackspace_api_key    => ENV['RAX_API_KEY'],
    :version => :v2,  # Use Next Gen Cloud Servers
    # :rackspace_region => :ord #Use Chicago Region
})

puts "Authenticated"
