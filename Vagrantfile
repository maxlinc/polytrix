# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu1310"
  config.vm.box_url = "https://dl.dropboxusercontent.com/s/ng79gg5bg24r38p/ubuntu1310.box?token_hash=AAGKH9rJTMozemrLMLw8n8Htvg8-gGhb7xo8cwh0TaYCaw&dl=1"

  config.cache.auto_detect = true

  config.vm.provision :shell, :inline => "curl -L https://opscode.com/chef/install.sh | bash"

  config.vm.provider :rackspace do |rs, override|
    override.vm.box = "dummy"
    override.ssh.private_key_path = '~/.ssh/id_rsa'
    rs.public_key_path = '~/.ssh/id_rsa.pub'
    rs.username = ENV['RAX_USERNAME']
    rs.api_key  = ENV['RAX_API_KEY']
    rs.flavor   = /2 GB Performance/
    rs.image    = "DRG" # image created by packer.  See ./packer/
    rs.rackspace_region = :ord
  end

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = ["packer/cookbooks", "packer/vendor/cookbooks"]
    chef.add_recipe "drg"
    # chef.log_level = :debug
   end

end
