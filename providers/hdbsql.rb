def print_sql_commands
  res = ''
  if @new_resource.print_sql_commands
    res = ' -f'
  end
  return res
end

def print_table_header
  res = ' '
  if !@new_resource.print_table_header
    res = ' -a '
  end
  return res
end

def output_file_path
  res = ''
  if !@new_resource.output_file_path.nil?
    res = " -o #{@new_resource.output_file_path}"
  end
  return res
end

def expected_exit_codes
  res = [0]
  if !@new_resource.expected_exit_codes.nil?
    res = @new_resource.expected_exit_codes
  end
  return res
end

action :run do
  command_to_execute = "#{node[:hana][:installpath]}/hdbclient/hdbsql" + print_sql_commands + print_table_header + "-n #{@new_resource.host} -i #{@new_resource.instance_number} -m -u #{@new_resource.username} -p"
  command_for_logging = "#{command_to_execute} *********" + output_file_path
  command_to_execute = "#{command_to_execute} #{@new_resource.password}" + output_file_path

  if @new_resource.sql_command != ""
    command_to_execute = "#{command_to_execute} \"#{@new_resource.sql_command}\""
    command_for_logging = "#{command_for_logging} \"#{@new_resource.sql_command}\""
  else
    if @new_resource.sql_file_path != ""
      command_to_execute = "#{command_to_execute} -c '#{@new_resource.sql_file_command_separator}' -I #{@new_resource.sql_file_path}"
      command_for_logging = "#{command_for_logging} -c '#{@new_resource.sql_file_command_separator}' -I #{@new_resource.sql_file_path}"
    else
      Chef::Log.error "You have to use either sql_command or sql_file_path attributes"
    end
  end

  execute "Running hdbsql command - #{command_for_logging}" do
    command "#{command_to_execute}"
    returns expected_exit_codes
  end
end
