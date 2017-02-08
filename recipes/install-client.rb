# Cookbook Name:: hana
# Recipe:: install-client
# Installs SAP Hana client on the node.

if !File.exists?("#{node['hana']['installpath']}/hdbclient")

  client "run install hana client" do
  end

end
