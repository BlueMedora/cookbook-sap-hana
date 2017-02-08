define :download_dataset, :datasetname => nil do
  Chef::Log.info "Download #{params[:datasetname]} to #{node['hana']['installpath']}/dataset/#{params[:datasetname]}"

  dataset_url = "#{node['install']['files']['datasetsources']}#{params[:datasetname]}"
  path_file = "#{node['install']['tempdir']}/dataset/"

  bash "Downloading #{params[:datasetname]} [ #{dataset_url} ] in #{path_file} " do
    code <<-EOH
          wget -P #{path_file} #{dataset_url}
    EOH
    not_if { ::File.exists?("#{node['install']['tempdir']}/dataset/#{params[:datasetname]}") }
  end

  bash "unzipe #{params[:datasetname]}" do
    code <<-EOS
          unzip  #{node['install']['tempdir']}/dataset/"#{params[:datasetname]}" -d #{node['install']['tempdir']}/dataset/
    EOS
    action :run
    not_if { ::Dir.exists?("#{node['install']['tempdir']}/dataset/#{File.basename(params[:datasetname], File.extname(params[:datasetname]))}/") }
  end

  bash "chmod 777 to dataset folder" do
    code <<-EOS
          chmod -R 777 #{node['install']['tempdir']}/dataset/
      EOS
    action :run
  end
end
