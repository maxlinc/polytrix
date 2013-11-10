#!/usr/bin/env python

import os
import pyrax

pyrax.set_setting("identity_type", "rackspace")
pyrax.set_credentials(os.getenv('RAX_USERNAME'), os.getenv('RAX_API_KEY'))
print "Authenticated"