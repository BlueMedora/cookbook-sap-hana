define :server, :exe => "" do
  if "#{node['hana']['checkhardware']}".chomp != "true"
    hana_install_command = "export HDB_COMPILEBRANCH=1 && export HDB_IGNORE_HANA_PLATFORM_CHECK=1 && #{params[:exe]} --ignore=#{node['hana']['checkstoignore']}"
  else
    hana_install_command = "#{params[:exe]}"
  end

  # check if a custom install path is defined - if yes, we create the dir to be sure
  if "#{node['hana']['installpath']}" != ""
    Chef::Log.info "a custom install path #{node['hana']['installpath']} is defined and will be created if not there yet"
    directory node['hana']['installpath'] do
      recursive true
      action :create
    end
  end

  # do the thext two things not in the case of the upgrader
  if hana_install_command.include? 'hdbupd'
    Chef::Log.info "update detected, thus skipping the data path and log path cmdline options"
  else
    Chef::Log.info "non update detected, thus checking the data path and log path cmdline options"
    # check if a custom data path is defined - if yes, we add the corresponding option to the installer
    if "#{node['hana']['datapath']}" != ""
      Chef::Log.info "a custom data path #{node['hana']['datapath']} is defined and will be used for the installation"
      directory node['hana']['datapath'] do
        recursive true
        action :create
      end
      hana_install_command = "#{hana_install_command} --datapath=#{node['hana']['datapath']}"
    end

    # check if a custom log path is defined - if yes, we add the corresponding option to the installer
    if "#{node['hana']['logpath']}" != ""
      Chef::Log.info "a custom log path #{node['hana']['logpath']} is defined and will be used for the installation"
      directory node['hana']['logpath'] do
        recursive true
        action :create
      end
      hana_install_command = "#{hana_install_command} --logpath=#{node['hana']['logpath']}"
    end

  end

  # check if a virtual hostname is defined - if yes, we add the corresponding option to the installer
  if "#{node['hana']['hostname']}" != ""
    Chef::Log.info "a custom hostname #{node['hana']['hostname']} is defined and will be used for the installation"
    hana_install_command = "#{hana_install_command} --hostname=#{node['hana']['hostname']}"
  end

  log "---------"
  log "will use installer from #{node['install']['files']['hanadb']}"
  log "---------"

  hdbcmd "run install / upgrade hana node" do
    exe "#{hana_install_command}"
    bin_dir "SAP_HANA_DATABASE"
    bin_file_url "#{node['install']['files']['hanadb']}"
  end
end
