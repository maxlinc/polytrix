#!/usr/bin/env ruby

require 'fog'

connection_opts = {
    :rackspace_username   => ENV['RAX_USERNAME'],
    :rackspace_api_key    => ENV['RAX_API_KEY'],
    :rackspace_region     => ENV['RAX_REGION'].downcase.to_sym,
    :rackspace_auth_url   => "#{ENV['RAX_AUTH_URL']}/v2.0"
}

# Compute services:
compute = Fog::Compute.new(connection_opts.merge({:provider => 'rackspace'}))
puts "Servers: #{compute.servers.all}"
puts "Networks: #{compute.networks.all}"

load_balancers = Fog::Rackspace::LoadBalancers.new(connection_opts)
puts "Cloud Load Balancers: #{load_balancers.load_balancers.all}"

storage = Fog::Storage.new(connection_opts.merge({:provider => 'rackspace'}))
puts "Cloud Files Containers: #{storage.directories.all}"

databases = Fog::Rackspace::Databases.new(connection_opts)
puts "Cloud Databases: #{databases.instances.all}"

dns = Fog::DNS::Rackspace.new(connection_opts)
puts "Cloud DNS: #{dns.zones.all}"

identity = Fog::Rackspace::Identity.new(connection_opts)
puts "Cloud Identity Users: #{identity.users.all}"

monitoring = Fog::Rackspace::Monitoring.new(connection_opts)
puts "Cloud Monitoring Account: #{monitoring.list_entities}"

block_storage = Fog::Rackspace::BlockStorage.new(connection_opts)
puts "Cloud Block Storage Volumes: #{block_storage.volumes.all}"

# Cloud Backup?

autoscale = Fog::Rackspace::AutoScale.new(connection_opts)
puts "Autoscale Scaling Groups: #{autoscale.groups.all}"

# Cloud Queues
queues = Fog::Rackspace::Queues.new(connection_opts)
puts "Cloud Queues: #{queues.queues.all}"
