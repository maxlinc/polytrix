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

puts 'Uploading folder'
local_directory = Pathname.new folder_to_upload
remote_directory = storage.directories.create :key => container_name
Dir["#{folder_to_upload}/**.*"].each do |file|
  file_key = Pathname.new(file).relative_path_from local_directory
  remote_directory.files.create :key => file_key.to_s, :body => File.open(file)
end
puts 'Done uploading'
