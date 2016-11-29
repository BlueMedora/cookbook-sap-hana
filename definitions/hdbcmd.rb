define :hdbcmd, :exe => "", :bin_dir => "", :bin_file_url => "" do

  # check for platform and install libraries
  include_recipe "hana::install-libs"

  # unless $already_done
    directory "Create temporary directory" do
      path "#{node['install']['tempdir']}"
      action :create
      recursive true
    end
#replace execute provider with remote_file provider
=begin
#    execute "Get SAPCAR tool for Hana extracting hana package" do
#      cwd "#{node['install']['tempdir']}"
#      command "wget #{node['install']['files']['sapcar']}"
#    end
 
  # end

#    execute "Get SAPCAR tool for Hana extracting hana package" do
#      cwd "#{node['install']['tempdir']}"
#      command "cp #{node['install']['files']['sapcar']} ."
#    end
=end 
    remote_file "#{node['install']['tempdir']}/SAPCAR" do
      source "#{node['install']['files']['sapcar']}"
      action :create
    end
=begin
  if params[:bin_file_url].start_with?("http")
    execute "Get Hana binary package" do
      cwd "#{node['install']['tempdir']}"
      command "wget --progress=dot:giga #{params[:bin_file_url]} -O SAP_HANA_PACKAGE.SAR"
    end

  elsif params[:bin_file_url].start_with?("/")
    execute "Get Hana binary package" do
      cwd "#{node['install']['tempdir']}"
      command "cp #{params[:bin_file_url]} SAP_HANA_PACKAGE.SAR"
    end
=end
    remote_file "#{node['install']['tempdir']}/IMDB_SERVER100_112_7-10009569.SAR" do
      source "#{node['install']['files']['hanadb']}"
      action :create
    end
    ######
    #repeated code block ot fix syntax issue, fix soon! 11-21-16
    #######
    if params[:bin_file_url].start_with?("http")
    execute "Get Hana binary package" do
      cwd "#{node['install']['tempdir']}"
      command "wget --progress=dot:giga #{params[:bin_file_url]} -O SAP_HANA_PACKAGE.SAR"
    end

  else
     unless $already_done
       directory "#{node['install']['productionmountpoint1']}" do
         action :create
         recursive true 
       end
      
       mount "#{node['install']['productionmountpoint1']}" do
         device "#{node['install']['productiondevice1']}"
         not_if "mountpoint -q #{node['install']['productionmountpoint1']}"
         fstype "nfs"
         action :mount
       end
  
       directory "#{node['install']['productionmountpoint2']}" do
         action :create
         recursive true 
       end
       mount "#{node['install']['productionmountpoint2']}" do
         device "#{node['install']['productiondevice2']}"
         not_if "mountpoint -q #{node['install']['productionmountpoint2']}"
         fstype "nfs"
         action :mount
       end
  
       directory "#{node['install']['productionmountpoint3']}" do
         action :create
         recursive true 
       end
       mount "#{node['install']['productionmountpoint3']}" do
         device "#{node['install']['productiondevice3']}"
         not_if "mountpoint -q #{node['install']['productionmountpoint3']}"
         fstype "nfs"
         action :mount
       end
     end

    execute "Get     #{params[:bin_file_url]}" do
      cwd "#{node['install']['tempdir']}"
      command "cp #{params[:bin_file_url]} SAP_HANA_PACKAGE.SAR"
    end
  end

  #remote_file would fit both variants, but seems to be very slow compared to wget and cp
  #remote_file "Get SAP_HANA_PACKAGE.SAR file" do
  #    source "#{params[:bin_file_url]}"
  #    path "#{node['install']['tempdir']}/SAP_HANA_PACKAGE.SAR"
  #    backup false
  #end
  
  execute "Extract #{params[:bin_file_url]}" do
    cwd "#{node['install']['tempdir']}"
    command "chmod +x SAPCAR && ./SAPCAR -xvf SAP_HANA_PACKAGE.SAR"
  end

  execute "Delete  #{params[:bin_file_url]} copy to save space" do
    cwd "#{node['install']['tempdir']}"
    command "rm -f SAP_HANA_PACKAGE.SAR"
  end

  execute "Run: #{params[:exe]}" do
    cwd "#{node['install']['tempdir']}/#{params[:bin_dir]}"
    command "#{params[:exe]}"
  end

  # Note: readymade-XSauto requires the if-case. Contact D023081. 
  if node['hana']['retain_instdir'] 
    Chef::Log.info "Retaining installation directory for sub-sequent AFL installation."
  else
    rmtempdir "clean up /monsoon/tmp directory"
  end

  $already_done = true
end
