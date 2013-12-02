if node[:instance_role] == 'vagrant'
  node.override[:rbenv][:group_users] = ['vagrant']
end

include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"
include_recipe "rbenv::rbenv_vars"

rbenv_ruby "1.9.3-p448"
rbenv_ruby "2.0.0-p247" do
  ruby_version "2.0.0-p247"
  global true
end
