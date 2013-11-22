include_recipe 'apt'

node.force_override[:dnsmasq][:dns] = {
  # 'no-poll' => nil,
  # 'no-resolv' => nil,
  'bind-interfaces' => nil,
  'server' => '127.0.0.1',
  'address' => '/dev/127.0.0.1'
}

include_recipe 'dnsmasq'