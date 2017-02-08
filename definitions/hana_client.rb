define :hana_client, :action => :install, :release => "1.0", :revision => nil, :sid => nil, :install_dir => nil, :sap_stop => nil, :sap_start => nil do
  include_recipe "hana::install-libs"

  if params[:sap_stop]
    service params[:sap_stop] do
      action :stop
      only_if { params[:action] == :install || Gem::Version.new(`#{params[:install_dir]}/hdbsql -v`.split[2]) < Gem::Version.new("#{params[:release]}.#{params[:revision]}") }
    end
  end

  revision = params[:revision]
  release = params[:release]

  sap_media "SAP_HANA_CLIENT#{params[:release].tr('.', '')}0_#{params[:revision]}_Linux_on_x86_64" do
    extract_dir "#{node[:sapinst][:media_dir]}/hana_client-#{release}.#{revision}"
    repo_path "static/monsoon/hana/newdb/#{release}.#{revision}"
    only_if { params[:action] == :install || Gem::Version.new(`#{params[:install_dir]}/hdbsql -v`.split[2]) < Gem::Version.new("#{params[:release]}.#{params[:revision]}") }
  end

  execute "Upgrade HANA client" do
    cwd "#{node[:sapinst][:media_dir]}/hana_client-#{params[:release]}.#{params[:revision]}/SAP_HANA_CLIENT/"
    command "./hdbinst -a client -p #{params[:install_dir]} #{params[:sid] ? '-s ' + params[:sid] : ''}"
    only_if { params[:action] == :install || Gem::Version.new(`#{params[:install_dir]}/hdbsql -v`.split[2]) < Gem::Version.new("#{params[:release]}.#{params[:revision]}") }
  end

  if params[:sap_start]
    service params[:sap_start] do
      action :start
    end
  end
end
