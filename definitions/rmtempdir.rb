define :rmtempdir do
  directory "Delete installation directory" do
    Chef::Log.info "Deleting installation directory."
    path "#{node['install']['tempdir']}"
    recursive true
    action :delete
  end
end
