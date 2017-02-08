define :hdbcmd, :exe => "", :bin_dir => "", :bin_file_url => "" do
  # check for platform and install libraries
  include_recipe "hana::install-libs"

  # unless $already_done
    directory "Create temporary directory" do
      path "#{node['install']['tempdir']}"
      action :create
      recursive true
    end
 
    remote_file "#{node['install']['tempdir']}/SAPCAR" do
      source "#{node['install']['files']['sapcar']}"
      action :create
      backup false
    end

    remote_file "#{node['install']['tempdir']}/SAP_HANA_PACKAGE.SAR" do
      source "#{node['install']['files']['hanadb']}"
      action :create
      backup false
    end

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

end
