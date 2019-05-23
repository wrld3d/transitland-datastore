# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "centos/7"
  config.vm.provider :virtualbox do |vb|
    vb.customize ['modifyvm', :id,'--memory', '4096']
  end

  config.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: [".git/", "postgres-data/", "db/sample-changesets/", "gtfs/"], rsync__chown: false
  config.vm.network "private_network", ip: "192.168.3.10"
  config.vm.network "forwarded_port", guest: 3000, host: 3000
  
  config.vm.provider "virtualbox" do |vb|
    vb.name = 'transitland-datastore'
    vb.memory = 4096
    vb.cpus = 1
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end

  config.vm.provision :docker
  config.vm.provision :docker_compose, yml: "/vagrant/docker-compose.yml", run:"always"
	
end