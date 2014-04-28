# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'maxlinc/travis-worker-linux'

  config.cache.auto_detect = true

  config.vm.define :polytrix do |vm|
  end

  config.vm.provider :rackspace do |rs, override|
    override.vm.box = 'dummy'
    override.ssh.private_key_path = '~/.ssh/id_rsa'
    rs.public_key_path = '~/.ssh/id_rsa.pub'
    rs.username = ENV['RAX_USERNAME']
    rs.api_key  = ENV['RAX_API_KEY']
    rs.flavor   = /2 GB Performance/
    rs.image    = 'DRG' # image created by packer.  See ./packer/
    rs.rackspace_region = :ord
  end

end
