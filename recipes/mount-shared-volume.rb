# Cookbook Name:: hana
# Recipe:: mount-shared-volume
# Mount the shared volume for HANA distributed installs

# first a check is done, if the directory of the nfs share is
# exported from the given nfs server. note: it is only checked,
# if it is exported at all, but not if to a certain machine,
# so the mount might still fail (raising an exception in that
# case). the reason for this check is to guarantee proper order
# of installations, i.e. workers only after the nfs server is
# active and not to have a bulletproof mount.
ruby_block "Check NFS server export" do
  block do
    Chef::Log.info "Running mount-shared-volume.rb recipe:"

    # split the ressource attribute into exporting server and exported
    # directory
    mnt_source = "#{node['hana']['dist']['sharedvolume']}".split(':')
    # command used for checking the export
    check_export_cmd = "showmount --export --no-headers #{mnt_source[0]} | grep -q \"^#{mnt_source[1]} \""

    Chef::Log.info "- Checking if directory #{mnt_source[1]} from server #{mnt_source[0]} is exported via nfs"

    curr_try = 0
    result = system check_export_cmd
    while !result && (curr_try < node['hana']['dist']['waitcount'])
      curr_try = curr_try + 1
      Chef::Log.info "Sleeping for #{node['hana']['dist']['waittime']} seconds waiting for the shared volume to become available ..."

      # wait for the nfs export to be available
      sleep node['hana']['dist']['waittime']
      result = system check_export_cmd
    end

    # if it does not get available after waiting "waitcount" times
    # "waittime" seconds, raise an exception
    if (curr_try == (node['hana']['dist']['waitcount']))

      raise "Gave up waiting for the shared volume export of #{node['hana']['dist']['sharedvolume']} to become available. Please check the the shared volume setup."
    end
  end
end

log "- Creating the local directory #{node['hana']['installpath']} to mount the shared volume"

# create the directory, where to mount the shared volume
directory node['hana']['installpath'] do
  recursive true
  owner "root"
  group "root"
  mode "0755"
  action :create
end

log "- Mounting the shared volume to the local directory"

# mount the shared volume
mount node['hana']['installpath'] do
  fstype "nfs"
  options "#{node['hana']['dist']['sharedmountoptions']}"
  device "#{node['hana']['dist']['sharedvolume']}"
  dump 0
  pass 0
  # mount and add to fstab
  action [:mount, :enable]
end
