#!/usr/bin/env python

import os
import pyrax
# [Configure Pyrax](https://github.com/rackspace/pyrax/blob/master/docs/getting_started.md#pyrax-configuration)
# to use the Rackspace identity service.

pyrax.set_setting("identity_type", "rackspace")


# Change the authentication endpoint if requested, otherwise use the default
custom_endpoint = os.getenv('RAX_AUTH_URL')
if custom_endpoint is not None:
  pyrax._create_identity()
  # Pyrax requires the endpoint to contain the version
  pyrax.identity.auth_endpoint = custom_endpoint + '/v2.0/'

# Set the region, needs to be done before authenticating.
pyrax.set_setting('region', os.getenv('RAX_REGION'))

# [Authenticate](https://github.com/rackspace/pyrax/blob/master/docs/getting_started.md#authenticating)
# using an API key.
pyrax.set_credentials(os.getenv('RAX_USERNAME'), os.getenv('RAX_API_KEY'))

# Get the flavor and image for the test scenario.
flavor = os.getenv('SERVER1_FLAVOR')
image  = os.getenv('SERVER1_IMAGE')

# Create a [Cloud Servers](https://github.com/rackspace/pyrax/blob/master/docs/cloud_servers.md) connection.
cs = pyrax.cloudservers

# [Create a server](https://github.com/rackspace/pyrax/blob/master/docs/cloud_servers.md#creating-a-server)
server = cs.servers.create("Pyrax Server", image, flavor)
# and [wait for it to build](https://github.com/rackspace/pyrax/blob/master/docs/cloud_servers.md#waiting-for-server-completion).
pyrax.utils.wait_for_build(server, verbose=True)
