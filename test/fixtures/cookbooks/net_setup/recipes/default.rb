prefix='eth'
prefix='enp0s' if node['platform_family'] == 'rhel' && node['platform_version'].to_i >= 7

(4..8).to_a.each do |n|
  execute "add dummy interface #{prefix}#{n}" do
    command "ip link add dev #{prefix}#{n} type dummy"
    not_if "ip a show dev #{prefix}#{n}"
  end

  execute "online #{prefix}#{n}" do
    command "ip link set dev #{prefix}#{n} up"
    not_if "ip a show dev #{prefix}#{n} | grep UP"
    not_if { node['platform_family'] == 'rhel' && node['platform_version'].to_i >= 7 }
  end
end
