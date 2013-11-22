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
depends 'nodejs'
depends 'php'
depends 'java'
depends 'maven'
depends 'groovy'
depends 'dnsmasq'

recipe "drg", "Installs tools required for testing Rackspace SDKS."

%w{ ubuntu }.each do |os|
  supports os
end