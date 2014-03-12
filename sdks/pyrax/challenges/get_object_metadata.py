#!/usr/bin/env python

import os
import pyrax

pyrax.set_http_debug(True)
pyrax.set_setting("region", os.getenv("RAX_REGION"))
pyrax.set_setting("identity_type", "rackspace")
# Create the identity object
# pyrax._create_identity()
# Change its endpoint
pyrax.identity.auth_endpoint = os.getenv('RAX_AUTH_URL') + '/v2.0/'

# Identity Connection - Authenticate
pyrax.set_credentials(os.getenv('RAX_USERNAME'), os.getenv('RAX_API_KEY'))
# Cloud Files API - List Files
cf = pyrax.cloudfiles
cf.get_object_metadata(os.getenv('TEST_DIRECTORY'), os.getenv('TEST_FILE'))
