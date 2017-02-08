define :client do
  # Hana client can be "coupled" to a Hana installation on the same node by passing the parameter "-s SID".
  # If this is not given, i.e. the client is being installed on a stand-alone machine, set the node attribute "clientsid" to false.
  if "#{node['hana']['clientsid']}".chomp == "true"
    Chef::Log.info "Setting SID for Hana client to #{node['hana']['sid']}"
    sid = "-s #{node['hana']['sid']}"
  else
    Chef::Log.info "Not setting SID for Hana client (i.e. stand-alone installation)"
    sid = ""
  end

  log "---------"
  log "using the hana_install_command"
  log "---------"

  hana_install_command = "./hdbinst -a client -p #{node['hana']['installpath']}/hdbclient #{sid}"

  log "---------"
  log "will use client installer from #{node['install']['files']['hanaclient']}"
  log "---------"

  hdbcmd "run install hana client" do
    exe "#{hana_install_command}"
    bin_dir "SAP_HANA_CLIENT"
    bin_file_url "#{node['install']['files']['hanaclient']}"
  end
end
