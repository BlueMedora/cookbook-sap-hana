# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

# The project name is base for directories
# Will also be the hostname for your project (e.g.: http://projectname.local)

Vagrant.configure("2") do |config|
  config.vm.box = "dummy"
  config.vm.provider :aws do |aws, override|
    aws.access_key_id = ENV['AWS_ACCESS_KEY']
    aws.secret_access_key = ENV['AWS_SECRET_KEY']
    aws.region = ENV['AWS_REGION']
    aws.security_groups = "ssh allowed"
    aws.keypair_name = ENV['AWS_KEYPAIR_NAME']
    aws.ami = ENV['AWS_AMI']
    aws.instance_type = ENV['AWS_INSTANCE_TYPE']
    aws.block_device_mapping = [{ 'DeviceName' => '/dev/sda1', 'Ebs.VolumeSize' => 160 }]

    override.ssh.username = "ec2-user"
    override.ssh.private_key_path = "#{ENV['HOME']}/.ssh/#{ENV['AWS_KEYPAIR_NAME']}.pem"

    # install latest chef client
    config.vm.provision "shell",
                        inline: "[[ `which chef-solo` ]] || curl -L https://www.opscode.com/chef/install.sh | sudo bash"
    # Execute the HANA cookcook
    config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = ENV['COOKBOOK_PATH']
      chef.log_level = ENV['CHEF_LOG'] ? ENV['CHEF_LOG'].to_sym : :debug
      chef.add_recipe "hana::install"
    end
  end
end
