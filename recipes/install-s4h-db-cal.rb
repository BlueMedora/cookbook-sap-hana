# Cookbook Name:: hana
# Recipe:: install-s4h-db-cal
# Installs SAP Hana DB, for S4HANA, from a CAL image.

Chef::Log.info "Executing #{cookbook_name}::#{recipe_name}"

#needed for sap_media definition, all files will be downloaded to /hana insteaad of tmp
ENV["TMPDIR"] = "/hana"

repodir = "static/monsoon/sap/s4hana/pc/1503"

directory "/hana/usr_sap" do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# ln -s /hana/usr_sap /usr/sap
link "/usr/sap" do
  action     :create
  mode '0755'
  link_type  :symbolic
  to "/hana/usr_sap"
end

#download all *.SAR files of the CAL image: DBLOG, DBDATA, DBEXE
node[:s4h][:media].each do |disk|
  sap_media disk do
    repo_path "/static/monsoon/sap/s4hana/pc/#{node[:s4h][:version]}"
    extractDir "#{node[:s4h][:media_dir]}/#{disk}"
  end
end

#open all files using tar: DBLOG, DBDATA, DBEXE
node[:s4h][:media].each do |disk|
  bash "restore files HANA DB-S4H - #{disk}" do
    user "root"
    code <<-EOF

  set -e
  cd /hana
  cat files/#{disk}/INST_FINAL_TECHCONF/db*.tgz-* | tar -zpxvf - -C /
  touch /hana/files/#{disk}/install.finished

    EOF
    not_if { ::File.exists?("/hana/files/#{disk}/install.finished")}
  end

end


bash "HANA DB - hdbreg utility" do
  user "root"
  code <<-EOF

  set -e

  cd /hana

  chown -R 1000 data log shared usr_sap
  /hana/shared/H50/global/hdb/install/bin/hdbreg -b -password #{node[:s4g][:db][:passsourse]} -U 1000 --shell=/bin/sh -H hanavhost=#{node[:hostname]} -nostart
  touch /hana/shared/hdbreg.finished

  EOF
  not_if { ::File.exists?("/hana/shared/hdbreg.finished")}
end


bash "HANA DB - Convert Topology" do
  user "root"
  code <<-EOF

  set -e

  cd /hana
  su - h50adm  -c "hdbnsutil -convertTopology"
  touch /hana/shared/topology.finished

  EOF
  not_if { ::File.exists?("/hana/shared/topology.finished")}
end


log "starting HANA DB for the first time takes a few minutes"
bash "HANA DB - Start DB" do
  user "root"
  code <<-EOF

  set -e

  cd /hana
  su - h50adm  -c "HDB start"

  EOF
end
