#!/usr/bin/env python

import os
import pyrax

pyrax.set_setting("identity_type", "rackspace")
pyrax.set_credentials(os.getenv('RAX_USERNAME'), os.getenv('RAX_API_KEY'))

pyrax.set_http_debug(True)
pyrax.identity.auth_endpoint = os.getenv('RAX_AUTH_URL') + '/v2.0/'
# pyrax.identity.authenticate()

cs = pyrax.cloudservers
print cs.images.list()
print "Authenticated"