# DRG Tests #

This repo contains smoke tests for Rackspace SDKs.  In order to run it you'll either need:
  - Lots of dependencies installed on your laptop
  - VirtualBox & Vagrant, so you can install the necessary dependencies inside a local VM
  - Packer and Vagrant-Rackspace, so you can build images and use images on the Rackspace cloud to run tests

The last option can also be combined with Jenkins JClouds plugin in order to setup CI builds using the images produced by Packer.

## Dependencies

The tests will use package managers for each SDK where appropriate (e.g. bundler for fog, npm for pkgcloud, etc.)  You need to be setup at least to the point where those package managers can run.  You'll also need dnsmasq in order to intercept some of the HTTP transactions for testing purposes.  It is possible to set this all up on your own machine - but the easiest way is to use Vagrant, Packer, or anything else that will let you use the Chef scripts in the project (targeted for Ubuntu).

## Creating a DRG Image

### Packer

The easiest way to create an image is with [Packer](http://www.packer.io).

### Rackspace credentials

You need to create a `.rbenv-vars` file with your Rackspace credentials.  These will be loaded as environment variables when the tests run.  The file should contain:

```
RAX_USERNAME=<your_rackspace_username>
RAX_API_KEY=<your_rackspace_api_key>
```

### Getting a DRG box

There is a Vagrantfile in the project.  It uses a "DRG" box.  There isn't currently a published DRG box, so you'll need to produce your own.  You can:

* Comment out `config.vm.box = "drg"` and uncomment the other lines with an alternate box.
* Run `vagrant up`, `vagrant provision`, and then `vagrant package --output drg.box`.  These steps will take a while.
* Run `vagrant box add drg drg.box`
* You now have a drg box, and can restore the Vagrant file to it's original state.

### Running tests



### (Tenative) Roadmap
* Use standard, shared images (travis-images? vagrantcloud?)
* Integrate with travis-build for .travis.yml support
* Separate Polytrix framework from reference tests

### BHAG
* Run tests as an interactive course via a browser