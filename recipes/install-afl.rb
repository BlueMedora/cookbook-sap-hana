# Cookbook Name:: hana
# Recipe:: install-afl
# Installs Application Functional Library for SAP Hana memory management on the node.

# verify AFL does not already exist
# if Dir.glob("#{node['hana']['installpath']}/#{node['hana']['sid']}/exe/linuxx86_64/HDB_1.00.??.*/plugins/afl1")

# HANA must exist before installing HLM
include_recipe 'hana::install'

# set AFL install command
hana_install_command = "./hdbinst --batch --sid=#{node['hana']['sid']} -password #{node['hana']['password']}"

hdbcmd "run install of hana afl" do
  exe hana_install_command
  bin_dir "SAP_HANA_AFL"
  bin_file_url node['install']['files']['afl']
end

# else
#  log "AFL seems to be installed already, so skipping this step"
# end
