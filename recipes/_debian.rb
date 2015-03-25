directory '/etc/network/interfaces.d'

# Get the contents of the managed_directory on disk
directory_contents = Dir.glob('/etc/network/interfaces.d/*')

# Walk the resource collection to find managed device files
managed_files = run_context.resource_collection.all_resources.map do |r|
  "/etc/network/interfaces.d/#{r.device}" if [:debian_network_interface, :network_interface].include? r.declared_type
end.compact

# Remove any contents that appear to be unmanaged
# We use the File resource for this so that the activity is visibile
# to report handlers.
files_to_remove = directory_contents - managed_files
files_to_remove.each do |f|
  file f do
    action :delete
  end
end

cookbook_file '/etc/network/interfaces'

package 'vlan' do
  only_if { node['network_interfaces_v2']['vlan'] }
end
modules '8021q' do
  only_if { node['network_interfaces_v2']['vlan'] }
end

package 'ifenslave-2.6' do
  only_if { node['network_interfaces_v2']['bonding'] }
end
modules 'bonding' do
  only_if { node['network_interfaces_v2']['bonding'] }
end

package 'ifmetric' do
  only_if { node['network_interfaces_v2']['metrics'] }
end

package 'bridge-utils' do
  only_if { node['network_interfaces_v2']['bridge'] }
end
