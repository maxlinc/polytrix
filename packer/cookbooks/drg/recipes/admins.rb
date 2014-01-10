node.override['authorization']['sudo']['groups'] = ["sudo"]
node.override['authorization']['sudo']['passwordless'] = true
include_recipe 'sudo'

# Jenkins User... jenkins-jclouds plugin will setup the rest
user "jenkins" do
  supports :manage_home => true
  home '/jenkins'
end

# Make the person who created the image a backup admin user
backup_admin = ENV["RAX_USERNAME"]
log "Creating user #{backup_admin} as a backup admin"

user backup_admin do
  supports :manage_home => true
  home "/home/#{backup_admin}"
end

group "sudo" do
  action :modify
  members ["jenkins", backup_admin]
  append true
end

# /etc/sudoers should be set for "sudo" instead of "wheel", but let's add them just in case
group "wheel" do
  action :modify
  members ["jenkins", backup_admin]
  append true
end

directory "/home/#{backup_admin}/.ssh" do
  owner backup_admin
  group backup_admin
  mode 0700
  action :create
end

file "/home/#{backup_admin}/.ssh/authorized_keys" do
  owner backup_admin
  group backup_admin
  mode 0600
  content File.read(File.expand_path("~/.ssh/id_rsa.pub"))
end
