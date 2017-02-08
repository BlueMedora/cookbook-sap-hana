### Fix for SAP Security note 2183624 (see http://service.sap.com/sap/support/notes/2183624) ###

### IMPORTANT: In a distributed environment, only run on one master node !!!!!

template "Place script to potentially fix SAP Security note 2183624" do
  source "secNote_2183624.sh.erb"
  path "/usr/sap/#{node[:hana][:sid]}/home/security_note_2183624.sh"
  owner "#{node[:hana][:sid].downcase}adm"
  group "sapsys"
  mode 00744
  backup false
end

ruby_block "Execute script to fix SAP Security note 2183624 (if necessary)" do
  block do
    # Method to check whether a file contains the String
    def checkFile(fileName)
      if !File.exists?(fileName)
        false
      else
        entryExists = false
        File.open(fileName) do |inFile|
          while (line = inFile.gets)
            if line =~ /^ssfs_key_file_path/
              key, value = line.split("=", 2)
              if value =~ /SSFS_#{node[:hana][:sid]}.KEY/
                Chef::Log.info("*** SAP Security note 2183624: master key set in #{fileName}")
                entryExists = true
              end
            end
          end
        end
        entryExists
      end
    end

    # If prior execution of script failed, a flag file should have been created
    if File.exists?("/usr/sap/#{node[:hana][:sid]}/home/ssfs_key.err")
      Chef::Log.error("*** SAP Security note 2183624: file ssfs_key.err exists in sidadm's home ***")
      Chef::Log.error("***                          Please investigate !                        ***")
    else
      # First, check if master key file location is set, either on the SYSTEM or HOST layer
      # NOTE: ../SYS/.. is always on the actual host, not in the shared file system, hence hard-coded /usr/sap
      sysMatch = checkFile("/usr/sap/#{node[:hana][:sid]}/SYS/global/hdb/custom/config/global.ini")
      hostMatch = checkFile("#{node[:hana][:installpath]}/#{node[:hana][:sid]}/HDB#{node[:hana][:instance]}/#{node[:hostname]}/global.ini")

      unless sysMatch || hostMatch
        Chef::Log.info("*** SAP Security note 2183624: fix will be executed since no reference to master key found")
        # Execute the script
        system("su - #{node[:hana][:sid].downcase}adm -c /usr/sap/#{node[:hana][:sid]}/home/security_note_2183624.sh")
      end
    end
  end
  not_if "test -f /usr/sap/#{node[:hana][:sid]}/home/ssfs_key.changed"
end
