hana cookbook 
===========
This cookbook provides recipes for installing SAP Hana Server & Client / Sap Hana Client
Tested with Vagrant & AWS Provider
 
For more information, other SAP Cookbooks, questions and feedback please go to: [http://sapcc.github.io/sap-cookbook-docs/](http://sapcc.github.io/sap-cookbook-docs/)

Requirements
===========
### Platform

* AWS Image - Suse SLES 11 SP3 (checked on this AMI: ami-f1f5acc1 from region: us-west-2)
* approx. 25GB in the rootfs directory and 5GB for the specified directory in attribute `['install'].['tempdir']`
* AWS EC2 Instance Type: c4.4xlarge (Minimum requirements - tested on this type) 

### Attributes

All attributes have sane default values (See `attributes/default.rb`). You can install any supported component in this cookbook, without overriding any attributes. In case you need to override an attribute(s), use either a role or a wrapper cookbook. See examples in the examples section.

#### Attributes related to SAP Hana instance configuration.

* `['hana'].['installpath']` - the directory into which SAP Hana will be installed.
* `['hana'].['datapath']` - custom path for the data files, empty by default
* `['hana'].['logpath']` - custom path for the log files, empty by default
* `['hana'].['sid']` - the SID of the installation (HNA by default)
* `['hana'].['instance']` - the instance number of the installation (00 by default, it will be used with the xs port later)
* `['hana'].['userid']` - UID of the user SIDadm, which will be created during installation (1099 by default)
* `['hana'].['password']` - SIDadm's password (Password must be > 8, and latters in upper and lower case)
* `['hana'].['syspassword']` - password for database user SYSTEM (Password must be > 8, and latters in upper and lower case)
* `['hana'].['checkhardware']` - flag to circumvent SAP's check, whether the used hardware is certified and meets certain requirements. Bear in mind that this is **not** meant for production systems, and don't expect any support.
* `['hana'].['checkstoignore']` - installer checks to be ignored if the checkhardware flag is disabled
* `['hana'].['clientsid']` - flag to specify a stand-alone Hana client installation (see below)
* `['hana'].['import_content']` - flag to specify if HanaXS (default development) content will be imported while installation and/or upgrade

#### Attributes related to the installation process.
* `['install'].['tempdir']` - temporary directory needed during installation
* `['install'].['files'].['sapcar']` - URL to the SAPCAR tool (for extracting SAR files)
* `['install'].['files'].['hanadb']` - URL to the SAR file for the Hana installer
* `['install'].['files'].['hanaclient']` - URL to the SAR file for the Hana client installer


All attributes under ['install'].['files'] hierarchy, must be accessible by http get method from the node on which the installation is executed.
The structure of ['install'].['files'].['hanadb'] archive must be a sole folder named SAP_HANA_DATABASE and all installation files in it.
The structure of ['install'].['files'].['hanadb'] archive must be a sole folder named SAP_HANA_CLIENT and all installation files in it.

#### Attributes related to the distributed installation process.

* `['hana'].['dist'].['sharedvolume']` - the nfs path (i.e server:/path) to the shared disk where the HANA will be installed including the data files and the log files. Only NFS shares are supported now. This attribute should be either an empty string or not set at all in case of a single node installation.
* `['hana'].['dist'].['sharedmountoptions']` - The NFS share options.
* `['hana'].['dist'].['master-mode-required']` - Only required for distributed installs with newer HANA versions - see the comments in the enable-master-mode.rb recipe.
* `['hana'].['dist'].['waitcount']` - The number of wait loops for the NFS share to be available. Needed in case of distributed installation where the NFS share is being created in parallel to the SAP Hana node installations. Usually keep the defaults.
* `['hana'].['dist'].['waittime']` - How much time each loop will wait. Usually keep the defaults.

All attributes under ['hana'].['dist'] hierarchy are related to distributed SAP Hana system installation process. Override only if you are installing a distributed system.

---
Recipes
===========
### hana::install
Installs single SAP Hana database on the node. 

### hana::install-client
Installs SAP Hana client on the node. The client will be installed into `['hana']['installpath']`/hdbclient.  
The SAP Hana client installer accepts a parameter "*-s SID*", thereby "coupling" the client to a SAP Hana installation with the given SID on the same node.  
If a stand-alone installation of the SAP Hana client is desired (i.e. there is **no** SAP Hana installation on the node), set the node attribute `['hana']['clientsid']` to "false".

---
Usage
===========
### Single SAP Hana node
Add the **[hana::install]** recipe to a new node in your landscape if you're planning a vanilla installation of SAP Hana. Change/override any attributes as required.

#### Example
To install SAP Hana on a node, and override the installation path and the SYSTEM user password use the following role:

	
	name "hana-install-single"
	description "Role for installing SAP Hana server"

	override_attributes(
	  "hana" => {
	    "installpath" => "/your/path/hana",
	    "syspassword" => "YOUR-SECRET"
	  }
	)

	run_list "recipe[hana::install]"

### SAP Hana client on a node
For installing SAP Hana client on a node in your landscape, add the **[hana::install-client]** recipe to the node's run list. If it should be a stand-alone installation of SAP Hana client, set a node attribute `['hana']['clientsid']` to "false".

#### Example
To install SAP Hana client on a node, use the following role:

	name "hana-install-client"
	description "Role for installing SAP Hana client"

	override_attributes(
	  "hana" => {
	    "installpath" => "/your/path/hana"
	  }
	)

	run_list "recipe[hana::install-client]"

Usage
===========
### Deploying SAP Hana cookbook with Vagrant & AWS Provider (kitchen will be added in updated version)
- Install Vagrant and VirtualBox using standard Vagrant 1.1+ plugin installation methods. After
installing, `vagrant up` and specify the `aws` provider. An example is
shown below.

```
$ vagrant plugin install vagrant-aws
...
$ vagrant up --provider=aws
...
```

Of course prior to doing this, you'll need to obtain an AWS-compatible
box file for Vagrant.

## Quick Start

After installing the plugin (instructions above), the quickest way to get
started is to actually use a dummy AWS box and specify all the details
manually within a `config.vm.provider` block. So first, add the dummy
box using any name you want:

```
$ vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box
...
```

Please execute the following in order to complete installation.


Firstly please make sure you have a cloned repository of the cookbook.

	git clone https://github.com/sapcc/sap-hana-cookbook.git



Vagrant Prerequisites (Please execute these commands in you're shell environment where you will run the vagrant)

	
	a.  Fill in the AWS values of the following attributes:

     		export AWS_ACCESS_KEY='';
     		export AWS_SECRET_KEY='';
    		export AWS_REGION='';
    		export AWS_KEYPAIR_NAME='';
    		export AWS_AMI='ami-f1f5acc1';
    		export AWS_INSTANCE_TYPE='';
	
	b. Fill in the HANA-Cookbook Path value (without the cookbook dir itself)

 		export COOKBOOK_PATH='';     
		Example: COOKBOOK_PATH='/home/user/cookbooks/';


Cookbook Prerequisites: (Please fill in the following parameters in the HANA cookbook attributes/default.rb)

		# Source of binary files (please fill in the values with full address that holds the binary files)

		default['install']['files']['sapcar']               = ""

		default['install']['files']['hanadb']               = ""

		default['install']['files']['hanaclient']           = ""

		Example: default['install']['files']['sapcar']      = "https://someserver.com/SAPCAR"


