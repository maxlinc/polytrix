#!/usr/bin/env python

import os
import pyrax
import time

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
print 'Uploading folder'
upload_key, total_bytes = cf.upload_folder(folder_to_upload, container=container_name)
print "Total bytes to upload:", total_bytes
uploaded = 0
while uploaded < total_bytes:
    uploaded = cf.get_uploaded(upload_key)
    print "Progress: %4.2f%%" % ((uploaded * 100.0) / total_bytes)
    time.sleep(1)

print 'Done uploading'
