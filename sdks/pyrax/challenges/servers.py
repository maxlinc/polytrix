#!/usr/bin/env python

import os
import pyrax

pyrax.set_setting("identity_type", "rackspace")
# Create the identity object
pyrax._create_identity()
# Change its endpoint
pyrax.identity.auth_endpoint = os.getenv('RAX_AUTH_URL') + '/v2.0/'
pyrax.set_setting('region', os.getenv('RAX_REGION'))

# Authenticate
pyrax.set_credentials(os.getenv('RAX_USERNAME'), os.getenv('RAX_API_KEY'))

flavor = os.getenv('SERVER1_FLAVOR')
image  = os.getenv('SERVER1_IMAGE')
cs = pyrax.cloudservers
server = cs.servers.create("Pyrax Server", image, flavor)
pyrax.utils.wait_for_build(server, verbose=True)
