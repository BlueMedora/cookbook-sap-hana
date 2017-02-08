# Simple provider to encapsulate the actions of HLM

action :add_afl do
  command_string = "add_afl --afl_path #{@new_resource.archive_path}"

  hlmcli(command_string)

  new_resource.updated_by_last_action(true)
end

action :add_lca do
  command_string = "add_lca --lca_path #{@new_resource.archive_path}"

  hlmcli(command_string)

  new_resource.updated_by_last_action(true)
end

action :add_sda do
  command_string = "add_sda --sda_path #{@new_resource.archive_path}"

  hlmcli(command_string)

  new_resource.updated_by_last_action(true)
end

action :update_hlm do
  if @new_resource.update_source.eql? "marketplace"
    command_string = "update_hana_lifecycle_manager --confirm_dialog true --update_source #{@new_resource.update_source} --use_proxy #{@new_resource.use_proxy} --proxy_host #{@new_resource.proxy_host}  --proxy_port #{@new_resource.proxy_port} --smp_user #{@new_resource.smp_user} --smp_pwd #{@new_resource.smp_pass}"
  else
    command_string = "update_hana_lifecycle_manager --confirm_dialog true --update_source #{@new_resource.update_source} --hlm_file_path #{@new_resource.archive_path}"
  end

  hlmcli(command_string)

  new_resource.updated_by_last_action(true)
end

action :apply_sp do
  command_string = "apply_support_package_stack --confirm_dialog true  --update_source #{@new_resource.update_source} --instance_Nr #{node['hana']['instance']} --db_user SYSTEM --db_pwd #{node['hana']['syspassword']} "

  if @new_resource.update_source.eql? "marketplace"
    command_string = command_string + "--use_proxy #{@new_resource.use_proxy} --proxy_host #{@new_resource.proxy_host}  --proxy_port #{@new_resource.proxy_port} --smp_user #{@new_resource.smp_user} --smp_pwd #{@new_resource.smp_pass}"
  else
    command_string = command_string + "--inbox_directory #{@new_resource.archive_path}"
  end

  hlmcli(command_string)

  new_resource.updated_by_last_action(true)
end

action :deploy_content do
  command_string = "deploy_hana_content --confirm_dialog true --instance_Nr #{node['hana']['instance']} --db_user SYSTEM --db_pwd #{node['hana']['syspassword']} --content_file_path #{@new_resource.archive_path} --content_update_source remote"

  hlmcli(command_string)

  new_resource.updated_by_last_action(true)
end

action :add_host do
  command_string = "add_host --addhost_hostname #{@new_resource.hostname} --addhost_sapadm_pwd #{@new_resource.sapadm_pass} --addhost_role #{@new_resource.role} --addhost_memory #{node['hana']['sid']}=#{@new_resource.target_memory}"

  hlmcli(command_string)

  new_resource.updated_by_last_action(true)
end

action :add_system do
  # java is required for HLM to complete this task
  _which = Mixlib::ShellOut.new("which java")
  _which.run_command
  package "java-1_7_0-ibm" if _which.exitstatus == 1

  # build default log and data path if none is provided
  if @new_resource.target_datapath.nil?
    _datapath = "#{node['hana']['installpath']}/#{@new_resource.target_sid}/global/hdb/data"
  else
    _datapath = @new_resource.target_datapath
  end
  if @new_resource.target_logpath.nil?
    _logpath = "#{node['hana']['installpath']}/#{@new_resource.target_sid}/global/hdb/log"
  else
    _logpath = @new_resource.target_logpath
  end

  # will be using sidadm a lot so setting it as a variable
  _sidadm = "#{@new_resource.target_sid}adm".downcase

  # create the sidadm user
  user _sidadm do
    gid "sapsys"
    shell "/bin/sh"
    comment "SAP HANA Database System Administrator"
    home "/usr/sap/" + new_resource.target_sid + "/home"
  end

  # set sidadm password (lazy way)
  execute "Set sidadm pass" do
    command "echo '" + new_resource.target_pass + "' | passwd --stdin #{_sidadm}"
  end

  # create data and log dirs if they dont exist
  directory _datapath do
    mode "750"
    owner _sidadm
    group "sapsys"
    action :create
    recursive true
    not_if { ::File.directory?(_datapath) }
  end
  directory _logpath do
    mode "775"
    owner _sidadm
    group "sapsys"
    action :create
    recursive true
    not_if { ::File.directory?(_logpath) }
  end

  # make sapcontrol directory, it is necessary for many administrative actions
  directory "#{node['hana']['installpath']}/#{@new_resource.target_sid}/global/sapcontrol" do
    mode "755"
    owner _sidadm
    group "sapsys"
    action :create
    recursive true
    not_if { ::File.directory?("#{node['hana']['installpath']}/#{new_resource.target_sid}/global/sapcontrol") }
  end

  command_string = "add_hana_system --dvdpath #{@new_resource.archive_path} --new_system_sid #{@new_resource.target_sid} --sapmntpath #{node['hana']['installpath']} --instance_number #{@new_resource.target_instance} --memory_configuration #{@new_resource.target_memory} --datapath " + _datapath + " --logpath " + _logpath + " --master_password #{@new_resource.target_pass}"

  hlmcli(command_string)

  new_resource.updated_by_last_action(true)
end

action :remove_system do
  _command_string = "remove_hana_system --memory_configuration #{@new_resource.target_memory} --dvdpath #{@new_resource.archive_path}"

  # before doing anything make sure the cli exists
  if !::File.exist?("#{node['hana']['installpath']}/#{@new_resource.target_sid}/HLM/hlmcli/hlmcli.sh")
    raise "HANA Lifecycle Manager is not installed."
  end

  # run the HLM command from target
  execute "Execute HLM command line" do
    cwd "#{node['hana']['installpath']}/#{new_resource.target_sid}/HLM/hlmcli"
    command "./hlmcli.sh --sid #{new_resource.target_sid} --sidadm_pwd #{new_resource.target_pass} #{_command_string}"
  end

  ruby_block "sleep" do
    block do
      sleep 10 # allow HLM processes to stop
    end
  end

  # cleanup filesystem
  directory "#{node['hana']['installpath']}/#{@new_resource.target_sid}" do
    action :delete
    recursive true
    subscribes :delete, "ruby_block[sleep]", :immediately
  end

  new_resource.updated_by_last_action(true)
end

action :remove_host do
  _command_string = "remove_host --removehost_hostname #{@new_resource.hostname}"

  run_context.include_recipe "hana::install-client"

  # Create and run hdbsql commands
  _hdbsql_content = "CALL SYS.UPDATE_LANDSCAPE_CONFIGURATION('SET REMOVE','" + new_resource.hostname.split('.')[0] + "');\n"
  _hdbsql_content = _hdbsql_content + "CALL REORG_GENERATE(2,'');\n"
  _hdbsql_content = _hdbsql_content + "CALL REORG_EXECUTE(?);\n"

  file "/tmp/hdbsql_hostremove" do
    content _hdbsql_content
    action :create
  end

  hana_hdbsql "flag-host-as-removed" do
    sql_file_path "/tmp/hdbsql_hostremove"
    instance_number node['hana']['instance'].to_s
    username "SYSTEM"
    password node['hana']['syspassword']
  end

  # verify reorg is finished
  _hdbsql_command = "#{node['hana']['installpath']}/hdbclient/hdbsql -i #{node['hana']['instance']} -x -u SYSTEM -p #{node['hana']['syspassword']} 'SELECT REMOVE_STATUS FROM m_landscape_host_configuration'"
  ruby_block "verify-reorg" do
    block do
      _reorg_finish = 0
      for i in 1..6
        Chef::Log.info("Checking system reorganization status.")

        _grep = Mixlib::ShellOut.new("#{_hdbsql_command} | grep 'REORG FINISHED'")
        _grep.run_command
        Chef::Log.debug("RC:#{_grep.exitstatus} - " + _grep.stdout)
        if _grep.exitstatus == 0
          _reorg_finish = 1
          break
        end
        sleep 10
      end
      if _reorg_finish == 1
        self.notifies :run, resources(:ruby_block => "run-hlmcli-command"), :immediately
      else
        self.notifies :run, resources(:ruby_block => "handle-reorg-status"), :immediately
      end
    end
    subscribes :run, "hana_hdbsql[flag-host-as-removed]", :immediately
    notifies :delete, "file[/tmp/hdbsql_hostremove]", :immediately
  end

  ruby_block "handle-reorg-status" do
    block do
      raise "Table reorg did not finish, unsafe to remove host."
    end
    action :nothing
  end

  ruby_block "run-hlmcli-command" do
    block do
      hlmcli(_command_string)
    end
    action :nothing
  end

  new_resource.updated_by_last_action(true)
end

action :rename do
  # keep current sid, hostname, and sysnr if not set
  if @new_resource.target_sid.nil?
    new_sid = node['hana']['sid']
  else
    new_sid = @new_resource.target_sid
    Chef::Log.warn("HLM will be disconnected during the SID change, recipe will ignore ANY error.")
    force = TRUE
  end
  if @new_resource.hostname.nil?
    new_host = node['hostname']
  else
    new_host = @new_resource.hostname
  end
  if @new_resource.target_instance.nil?
    new_sysnr = node['hana']['instance']
  else
    if @new_resource.target_instance < 10
      new_sysnr = "0#{@new_resource.target_instance}"
    else
      new_sysnr = @new_resource.target_instance
    end
  end

  command_string = "rename_hana_system --target_password #{node['hana']['password']} --target_sid #{new_sid} --hostname #{new_host} --external_hostname #{new_host} --number #{new_sysnr}"

  if force
    hlmcli_force(command_string)
  else
    hlmcli(command_string)
  end

  new_resource.updated_by_last_action(true)
end

# basics of the hlmcli command
def hlmcli(operation)
  # before doing anything make sure the cli exists
  if !::File.exist?("#{node['hana']['installpath']}/#{node['hana']['sid']}/HLM/hlmcli/hlmcli.sh")
    raise "HANA Lifecycle Manager is not installed."
  end

  execute "Execute HLM command line" do
    cwd "#{node['hana']['installpath']}/#{node['hana']['sid']}/HLM/hlmcli"
    user # {node['hana']['sid'].downcase}adm
    command "./hlmcli.sh --sid #{node['hana']['sid']} --sidadm_pwd #{node['hana']['password']} #{operation}"
  end
end

# Run the hlmcli command and ignore errors
def hlmcli_force(operation)
  # before doing anything make sure the cli exists
  if !::File.exist?("#{node['hana']['installpath']}/#{node['hana']['sid']}/HLM/hlmcli/hlmcli.sh")
    raise "HANA Lifecycle Manager is not installed."
  end

  execute "Execute HLM command line" do
    cwd "#{node['hana']['installpath']}/#{node['hana']['sid']}/HLM/hlmcli"
    user # {node['hana']['sid'].downcase}adm
    command "./hlmcli.sh --sid #{node['hana']['sid']} --sidadm_pwd #{node['hana']['password']} #{operation}"
    returns [0, 1]
  end
end
