if node[:instance_role] == 'vagrant'
  # Ideally would be group_users, but see https://github.com/RiotGames/rbenv-cookbook/issues/44
  # node.override[:rbenv][:group_users] = ['vagrant']
  node.override[:rbenv][:user] = 'vagrant'
else
  node.override[:rbenv][:user] = 'jenkins'
end

include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"
include_recipe "rbenv::rbenv_vars"

rbenv_ruby "1.9.3-p448"
rbenv_ruby "2.0.0-p247" do
  ruby_version "2.0.0-p247"
  global true
end

rbenv_gem "bundler" do
  ruby_version "1.9.3-p448"
end

rbenv_gem "bundler" do
  ruby_version "2.0.0-p247"
end
