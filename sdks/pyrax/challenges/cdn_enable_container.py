#!/usr/bin/env python

import os
import pyrax

container_name = 'my-site'
folder_to_upload = os.getenv('TEST_DIRECTORY')
username = os.getenv('RAX_USERNAME')
api_key = os.getenv('RAX_API_KEY')
auth_endpoint = os.getenv('RAX_AUTH_URL')

pyrax.set_setting("identity_type", "rackspace")
# Create the identity object
pyrax._create_identity()
# Change its endpoint
pyrax.identity.auth_endpoint = auth_endpoint + '/v2.0/'

# Identity Connection - Authenticate
pyrax.set_credentials(username, api_key)

cf = pyrax.cloudfiles
cf.make_container_public(container_name, ttl=900)
