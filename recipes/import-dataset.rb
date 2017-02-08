
Chef::Log.info "Create folder #{node['hana']['source']}#{node['hana']['dataset']}"

directory "#{node['install']['tempdir']}/dataset" do
  action :create
  mode 0777
  recursive true
end

datasetnames = node['install']['files']['datasetnames']

if datasetnames.is_a?(String) then
  datasetnames = [datasetnames]
end

datasetnames.each do |currentdatasetname|
  download_dataset "Extract data set #{currentdatasetname}" do
    datasetname currentdatasetname
  end

  ruby_block "Create / execute SQL file" do
    block do
      data = File.basename(currentdatasetname, File.extname(currentdatasetname))

      Dir.glob("#{node['install']['tempdir']}/dataset/#{data}/**/").each do |dir|
        if Dir.exist?("#{dir}/index") || (dir.split('/').last == "index")

          if dir.split('/').last == "index"
            schema = Dir.glob(["#{dir}*/"])[0].split('/').last
            dir.slice!("index/")
          else
            schema = Dir.glob(["#{dir}index/*/"])[0].split('/').last
          end

          myfile = Chef::Resource::File.new("#{node['install']['tempdir']}/dataset/sql_#{data}_#{schema}.sql", run_context)
          myfile.content "\\connect -n 127.0.0.1 -i 00 -u SYSTEM -p #{node['hana']['syspassword']};\n IMPORT \"#{schema}\".\"*\" AS BINARY FROM '#{dir}' WITH REPLACE;\n GRANT SELECT ON SCHEMA #{schema} TO _SYS_REPO WITH GRANT OPTION;"
          myfile.mode 0777
          myfile.run_action "create"

        else
          next
        end
      end

      Dir["#{node['install']['tempdir']}/dataset/*.sql"].each do |sql_file|
        mycmd = Chef::Resource::Bash.new("Execute #{sql_file}", run_context)
        mycmd.code "<<-EOS #{node['hana']['installpath']}/#{node['hana']['sid']}/HDB#{node['hana']['instance']}/exe/hdbsql -I #{sql_file} EOS"
        mycmd.run_action "run"
      end

      if node['install']['files']['deletedatasetsources']
        datasetfolder = Chef::Resource::Directory.new("#{node['install']['tempdir']}/dataset/", run_context)
        datasetfolder.recursive true
        datasetfolder.run_action "delete"
      end
    end
  end
end
