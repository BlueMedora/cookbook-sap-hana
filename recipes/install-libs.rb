# install required libraries for suse
if platform?("suse")

  if node["platform_version"].to_f < 11.3
    platformversion = node["platform_version"].to_f
    log "++++++ Will delete libstdc and libgcc because platform version is #{platformversion} +++++++++++++"
    log "####################### removing libstdc++46 ########################"
    package "libstdc++46" do
      version "4.6.1_20110701-0.13.9"
      action :remove
    end

    log "####################### removing libgcc46 ########################"
    package "libgcc46" do
      version "4.6.1_20110701-0.13.9"
      action :remove
    end
  end

  log "####################### Checking for libstdc++6 ########################"
  package "libstdc++6" do
    action :upgrade
  end

  log "####################### Checking for libgcc_s1 ########################"
  package "libgcc_s1" do
    action :upgrade
  end
elsif platform?("redhat")
  
  log "####################### Checking for Redhat dependencies ########################"
  rhel_packages = [ "libaio","libtool-ltdl","compat-sap-c++-5" ]
  rhel_packages.each do |pkg|
    package pkg do
      action :upgrade
    end
  end

else
  log "####################### Cookbook currently supports only SuSE platform ########################"
  raise "Your choosen platform #{node["platform"]} is not supported for Cookbook and HANA!"
end
