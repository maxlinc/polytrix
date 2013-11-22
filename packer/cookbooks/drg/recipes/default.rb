node.override['nodejs']['install_method'] = 'package'

include_recipe 'drg::system'
include_recipe 'python'
include_recipe 'drg::ruby'
include_recipe 'golang'
# It's getting stuck... perhaps on SSL keys for github?
# include_recipe 'node'
include_recipe 'drg::php'
# include_recipe 'drg::java'
