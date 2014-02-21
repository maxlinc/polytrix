#!/usr/bin/env python

import os
import pyrax

pyrax.set_http_debug(True)
pyrax.set_setting("identity_type", "rackspace")
# Create the identity object
pyrax._create_identity()
# Change its endpoint
pyrax.identity.auth_endpoint = os.getenv('RAX_AUTH_URL') + '/v2.0/'

# Identity Connection - Authenticate
pyrax.set_credentials(os.getenv('RAX_USERNAME'), os.getenv('RAX_API_KEY'))
print "Authenticated"

# Cloud Servers API - List Servers
cs = pyrax.cloudservers
print "Servers:", cs.servers.list()

# Networks API - List Networks
cnw = pyrax.cloud_networks
print "Networks:", cnw.list()

# Cloud Files API - List Files
cf = pyrax.cloudfiles
cf.http_log_debug = True
print "Cloud Files Containers:", cf.list_containers()

# Cloud Load Balancers
clb = pyrax.cloud_loadbalancers
print "Cloud Load Balancers:", clb.list()

# Cloud Database
cdb = pyrax.cloud_databases
print "Cloud Databases:", cdb.list()

# Cloud DNS
cdns = pyrax.cloud_dns
print "Cloud DNS:", cdns.list()

# Cloud Identity
# print "Cloud Identity Users:", pyrax.identity.list_users()

# Cloud Monitoring
cm = pyrax.cloud_monitoring
print "Cloud Monitoring Account:", cm.get_account()

# Cloud Block Storage
cbs = pyrax.cloud_blockstorage
print "Cloud Block Storage Volumes:", cbs.list()

# Cloud Backup?

# Autoscale
ax = pyrax.autoscale
print "Autoscale Scaling Groups:", ax.list()

# Cloud Queues
pq = pyrax.queues
print "Cloud Queues:", pq.list()
