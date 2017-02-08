action :set do
  command_to_execute = "#{node[:hana][:installpath]}/hdbclient/hdbuserstore set #{@new_resource.key} #{@new_resource.host}:3#{@new_resource.instance_number}15 #{@new_resource.username} "
  command_to_log = "#{command_to_execute} ***********"
  command_to_execute = "#{command_to_execute} #{@new_resource.password}"
  execute "Running hdbuserstore command - #{command_to_log}" do
    command "#{command_to_execute}"
  end
end

action :delete do
  command_to_execute = "#{node[:hana][:installpath]}/hdbclient/hdbuserstore delete #{@new_resource.key}"

  execute "Running hdbuserstore command - #{command_to_execute}" do
    command "#{command_to_execute}"
  end
end
