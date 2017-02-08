if !File.exists?("#{node['hana']['installpath']}/#{node['hana']['sid']}/HDB#{node['hana']['instance']}/#{node['hostname']}/sec/cred_v2")

  SIDADM = "#{node['hana']['sid']}adm".downcase

  # template "#{node['hana']['installpath']}/#{node['hana']['sid']}/HDB#{node['hana']['instance']}/#{node['hostname']}/sec/#{node['hostname']}-#{node['hana']['sid']}.crt" do
  #  source "host.crt"
  #  user "#{node['hana']['sid']}adm".downcase
  #  group "sapsys"
  #  mode 00644
  # end

  cookbook_file "#{node['hana']['installpath']}/#{node['hana']['sid']}/HDB#{node['hana']['instance']}/#{node['hostname']}/sec/SAPNetCA.cer" do
    source "SAPNetCA.cer"
    user "#{SIDADM}"
    group "sapsys"
    mode 00644
  end

  csh "sapgenpse import own cert" do
    user "#{SIDADM}"
    group "sapsys"
    cwd "#{node['hana']['installpath']}/#{node['hana']['sid']}/HDB#{node['hana']['instance']}/#{node['hostname']}/sec"
    code <<-EOH
    setenv LD_LIBRARY_PATH #{node['hana']['installpath']}/#{node['hana']['sid']}/global/security/lib
    #{node['hana']['installpath']}/#{node['hana']['sid']}/global/security/lib/sapgenpse import_own_cert -p #{node['hana']['installpath']}/#{node['hana']['sid']}/HDB#{node['hana']['instance']}/#{node['hostname']}/sec/sapsrv.pse -c #{node['hostname']}-#{node['hana']['sid']}.crt -x '' -r SAPNetCA.cer
    EOH
  end

  log "sapgenpse seclogin create cred_v2 file"
  bash "sapgenpse seclogin create cred_v2 file" do
    cwd "#{node['hana']['installpath']}/#{node['hana']['sid']}/HDB#{node['hana']['instance']}/#{node['hostname']}/sec"
    code <<-EOH
  su - #{SIDADM} -c "#{node['hana']['installpath']}/#{node['hana']['sid']}/global/security/lib/sapgenpse seclogin -p sapsrv.pse -x '' "
  EOH
    environment 'LD_LIBRARY_PATH' => "#{node['hana']['installpath']}/#{node['hana']['sid']}/global/security/lib"
  end

  bash "restart webdispatcher and xsengine" do
    user "#{node['hana']['sid']}adm".downcase
    group "sapsys"
    cwd "#{node['hana']['installpath']}/#{node['hana']['sid']}/HDB#{node['hana']['instance']}/#{node['hostname']}/trace"
    code <<-EOH
  kill -9 `pidof hdbxsengine`
  kill -9 `pidof sapwebdisp_hdb`
  sleep 15
  EOH
  end

else
  Chef::Log.info "################# Seems certificate already has been imported, for new cert import delete #{node['hana']['installpath']}/#{node['hana']['sid']}/HDB#{node['hana']['instance']}/#{node['hostname']}/sec/cred_v2 first ###################"
  log "################# Seems certificate already has been imported, for new cert import delete #{node['hana']['installpath']}/#{node['hana']['sid']}/HDB#{node['hana']['instance']}/#{node['hostname']}/sec/cred_v2 first ###################"
end
