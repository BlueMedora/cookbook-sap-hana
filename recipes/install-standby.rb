# Cookbook Name:: hana
# Recipe:: install-standby
# Installs SAP Hana Standby on the node.

# check for platform and install libraries
include_recipe "hana::install-libs"

# check if there is a shared volume defined - if yes, mount it and continue, if no exit
if "#{node['hana']['dist']['sharedvolume']}" != ""
  Chef::Log.info "a shared volume #{node['hana']['dist']['sharedvolume']} is defined and will be mounted"
  include_recipe "hana::mount-shared-volume"
else
  raise "No shared volume defined, thus a worker node install is not possible"
end

# hdbupd needs a user with id=0 to update a worker in a distributed setup
if "#{node['hana']['dist']['2ndroot']}" != ""
  user "#{node['hana']['dist']['2ndroot']}" do
    supports :non_unique => true
    comment "second root user"
    home "/root"
    uid 0
    gid 0
    shell "/bin/bash"
    password "#{node['hana']['dist']['2ndrootpwd']}"
  end
end

# check if a hostname was specified
if "#{node['hana']['hostname']}" != ""
  Chef::Log.info "a custom hostname #{node['hana']['hostname']} is defined and will be used for the installation"
  hostname = "#{node['hana']['hostname']}"
else
  hostname = node[:hostname]
end

# make sure there is no hana worker installed yet on this machine
if !File.exists?("#{node['hana']['installpath']}/#{node['hana']['sid']}/HDB#{node['hana']['instance']}/#{hostname}/install.finished")

  # check if install of the master node is finished, by checking the install.finish file
  ruby_block "Wait for the HANA Master installation to finish" do
    block do
      # File should be in a path visible to all nodes, this path is on the nfs share which must be mounted
      # saperatly (defined in a role or any other place which runs before this recipe)
      install_finished_file = "#{node['hana']['installpath']}/#{node['hana']['sid']}/install.finished"

      curr_try = 0
      while (!File.exist?("#{install_finished_file}")) && (curr_try < node['hana']['dist']['waitcount'])
        # wait for the master node to finish installation
        curr_try = curr_try + 1
        Chef::Log.info "Sleeping for #{node['hana']['dist']['waittime']} seconds waiting for the installation of the master to finish ..."
        sleep node['hana']['dist']['waittime']
      end

      # if it does not get available after waiting "waitcount" times
      # "waittime" seconds, raise an exception
      if (curr_try == (node['hana']['dist']['waitcount']))
        raise "Gave up waiting for install finished file #{install_finished_file} to be created. Please check the master installation."
      end
    end
  end

  # build hana install command
  hana_install_worker_command = "./hdbaddhost --batch --sid=#{node['hana']['sid']} --hostname=#{hostname} --sapmnt=#{node['hana']['installpath']} --password=#{node['hana']['password']} --role=standby"
  if "#{node['hana']['checkhardware']}".chomp != "true"
    # hana_install_worker_command = "export HDB_COMPILEBRANCH=1 && export HDB_IGNORE_HANA_PLATFORM_CHECK=1 && #{hana_install_worker_command} --ignore=#{node['hana']['checkstoignore']}"
    hana_install_worker_command = "export HDB_COMPILEBRANCH=1 && export HDB_IGNORE_HANA_PLATFORM_CHECK=1 && #{hana_install_worker_command}"
  end

  # run hdbaddhost command to add a new worker machihe to existing HANA DB cluster
  log "Start to install HANA DB standby, running command: #{hana_install_worker_command}"
  execute "Install Hana standby..." do
    cwd "#{node['hana']['installpath']}/#{node['hana']['sid']}/global/hdb/install/bin"
    command "#{hana_install_worker_command}"
  end

  # write a file to the fs, which will state that the installation is finished, so if any worker installation runs, it can be sure
  # that the installation of this worker was finished successfully
  file "Create installation completion flag" do
    path "#{node['hana']['installpath']}/#{node['hana']['sid']}/HDB#{node['hana']['instance']}/#{hostname}/install.finished"
    action :create
  end

else
  log "It looks like there is already a hana standby installed on this node, so skipping this step"
end
