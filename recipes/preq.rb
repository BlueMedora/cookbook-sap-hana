
# node.set[:hana][:pre][:cpu] = '10'
# node.set[:hana][:pre][:ram] = '30227508'

req_cpu = defined?(node[:hana][:pre][:cpu]) ? node[:hana][:pre][:cpu] : 20
req_ram = defined?(node[:hana][:pre][:ram]) ? node[:hana][:pre][:ram].gsub("kb", "") : '130227508'

# Chef::Log.info "req_cpu = #{req_cpu},  req_ram = #{req_ram}"

if node["cpu"]["total"].to_i < req_cpu.to_i
  raise "This cookbook requires at least #{req_cpu} cores to function correctly"
else
  Chef::Log.info "#{cookbook_name}::#{recipe_name} found #{node['cpu']['total']} cpu's"
end

if node['memory']['total'].gsub("kb", "").to_i < req_ram.to_i
  raise "This cookbook requires at least #{req_ram} of RAM to function correctly"
else
  Chef::Log.info "#{cookbook_name}::#{recipe_name} found #{node['memory']['total']} RAM"
end

Chef::Log.info "Prequisite check completes successfuly - continuing execution ..."
