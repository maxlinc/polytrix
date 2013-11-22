name              "drg"
maintainer        "Rackspace US, Inc"
maintainer_email  "sdk-support@rackspace.com"
license           "MIT"
description       "Installs tools required for testing Rackspace SDKS."
version           "0.0.1"

depends 'apt'
depends 'python'
depends 'rbenv'
depends 'golang'
depends 'node'
depends 'php'
depends 'java'
depends 'maven'
depends 'dnsmasq'

recipe "drg", "Installs tools required for testing Rackspace SDKS."

%w{ ubuntu }.each do |os|
  supports os
end