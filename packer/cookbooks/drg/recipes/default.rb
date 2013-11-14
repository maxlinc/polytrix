node.override['nodejs']['install_method'] = 'package'

include_recipe 'apt'
include_recipe 'python'
include_recipe 'rbenv'
include_recipe 'golang'
# It's getting stuck... perhaps on SSL keys for github?
# include_recipe 'node'
include_recipe 'php'
include_recipe 'java'
