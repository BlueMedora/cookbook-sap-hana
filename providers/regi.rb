def get_regi_command
  "#{node[:hana][:installpath]}/hdbclient/regi "
end

def add_force
  res = ''
  if @new_resource.force
    res = ' --force'
  end
  res
end

def cascade_package
  res = 'package'
  if @new_resource.cascade
    res = 'packages'
  end
  res
end

def update
  new_resource.updated_by_last_action(true)
end

action :create_workspace do
  admin_user = node['hana']['sid'].downcase + "adm"
  currenthanaversion = `su --login #{admin_user} -c 'HDB version' | grep version: | awk -F \. '{ print $3 }'`

  # first create the directory
  directory "#{new_resource.workspace_path}" do
    recursive true
    action :create
    mode 0755
  end

  if currenthanaversion.to_i > 69
    command_to_execute = get_regi_command + "create workspace . --key=#{@new_resource.key}" + add_force
  else
    command_to_execute = get_regi_command + "create workspace --key=#{@new_resource.key}" + add_force
  end
  execute "Running regi create_workspace - #{command_to_execute}" do
    cwd new_resource.workspace_path
    command "#{command_to_execute}"
  end
  update
end

action :delete_workspace do
  directory "#{new_resource.workspace_path}" do
    recursive true
    action :delete
    mode 0755
  end
  update
end

action :export_delivery_unit do
  command_to_execute = get_regi_command + "export #{@new_resource.delivery_unit_name} #{@new_resource.delivery_unit_vendor} #{@new_resource.delivery_unit_path}/#{@new_resource.delivery_unit_name}.tgz"
  execute "Running regi export_delivery_unit - #{command_to_execute}" do
    cwd new_resource.workspace_path
    command "#{command_to_execute}"
  end
  update
end

action :import_delivery_unit do
  command_to_execute = get_regi_command + "import file #{@new_resource.delivery_unit_path}"
  execute "Running regi import_delivery_unit - #{command_to_execute}" do
    cwd new_resource.workspace_path
    command "#{command_to_execute}"
  end
  update
end

action :track_package do
  command_to_execute = get_regi_command + "track package #{@new_resource.package}"
  execute "Running regi track_package - #{command_to_execute}" do
    cwd new_resource.workspace_path
    command "#{command_to_execute}"
  end
  update
end

action :untrack_package do
  command_to_execute = get_regi_command + "untrack package #{@new_resource.package}"
  execute "Running regi untrack_package - #{command_to_execute}" do
    cwd new_resource.workspace_path
    command "#{command_to_execute}"
  end
  update
end

action :delete_package do
  command_to_execute = get_regi_command + "delete " + cascade_package + " #{@new_resource.package}"
  execute "Running regi delete_package - #{command_to_execute}" do
    cwd new_resource.workspace_path
    command "#{command_to_execute}"
  end
  update
end

action :checkout do
  execute_activate_or_revert('checkout')
end

action :commit do
  execute_activate_or_revert('commit')
end

def execute_activate_or_revert(command)
  command_to_execute = get_regi_command + "#{command} "
  if new_resource.object_type == "inactiveObjects"
    command_to_execute = "#{command_to_execute} inactiveObjects"
  elsif new_resource.object_type == "trackedPackages"
    command_to_execute = "#{command_to_execute} trackedPackages"
  elsif !new_resource.package.nil?
    command_to_execute = "#{command_to_execute}" + cascade_package + " #{@new_resource.package}"
  elsif !new_resource.object.nil?
    command_to_execute = "#{command_to_execute} #{@new_resource.object}"
  end

  execute "Running regi #{command} - #{command_to_execute}" do
    cwd new_resource.workspace_path
    command "#{command_to_execute}"
  end
  update
end

action :activate do
  execute_activate_or_revert('activate')
end

action :revert do
  execute_activate_or_revert('revert')
end
