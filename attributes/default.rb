# Default Attributes file of HANA Server & Client (Hana Single)

# HANA Server general attributes
default['hana']['installpath']    = "/hana/shared"
default['hana']['datapath']       = ""
default['hana']['logpath']        = ""
default['hana']['sid']            = "HNA"
default['hana']['instance']       = "00"
default['hana']['userid']         = "1099"

## Password must be > 8 chars with letters in up & low case
default['hana']['password']       = "1234Test"
default['hana']['syspassword']    = "1234Test"
default['hana']['checkhardware']  = "true"
default['hana']['checkstoignore'] = "check_platform,check_diskspace,check_min_mem"
default['hana']['clientsid']      = "false"
default['hana']['import_content'] = "on"
default['hana']['nostart']        = "off"
default['hana']['hostname']       = "" # This should be recognized by chef environment (ohai..) so you can leave this empty.

# HANA HDI needs parameterized autostart/xs_engine, because want to set off
default['hana']['autostart']      = "on"
default['hana']['xs_engine']      = "on"
default['hana']['import_content'] = "on"
default['hana']['xs_http_port']   = "80" + node['hana']['instance']
default['hana']['xs_https_port']  = "443"

# Attributes for landscape deployment (for several HANA servers) - this is not used for HANA-single environment.
default['hana']['dist']['sharedvolume']         = ""
default['hana']['dist']['sharedmountoptions']   = ""
default['hana']['dist']['master-mode-required'] = "false"
default['hana']['dist']['waitcount']            = 5
default['hana']['dist']['waittime']             = 5

## Temp dir for installation - must be something valid.
default['install']['tempdir']               = "/monsoon/tmp"

#### Attributes for binary downloads
# Source of binary files (please replace server with you're server name that holds the binary files)
default['install']['files']['sapcar']               = ""
default['install']['files']['hanadb']               = ""
default['install']['files']['hanaclient']           = ""
