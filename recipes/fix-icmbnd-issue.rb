
# This should actually be handled by hdblcm/hdbinst/hdbupd...
# However, by having a separate recipe we can fix existing systems quickly
# Remove this recipe when issue is tackled at the source and live systems
# no longer contain the icmbnd-related defect.

bash "activate external icmbnd" do
  cwd "#{node['hana']['installpath']}/#{node['hana']['sid']}/SYS/exe/hdb"
  code <<-EOH
    cp icmbnd.new icmbnd
    chown root:sapsys icmbnd
    chmod 4750 icmbnd
  EOH
end

bash "restart webdispatcher and xsengine" do
  user "#{node['hana']['sid']}adm".downcase
  group "sapsys"
  cwd "#{node['hana']['installpath']}/#{node['hana']['sid']}/HDB#{node['hana']['instance']}/#{node['hostname']}/trace"
  code <<-EOH
  kill -9 `pidof hdbxsengine`
  kill -9 `pidof sapwebdisp_hdb`
  sleep 30
  EOH
end
