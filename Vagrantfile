# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

 	config.vm.provider "virtualbox" do |vb|
    	vb.customize ["modifyvm", :id, "--memory", "1024"]
 	end

  	config.vm.box = "puppetlabs/ubuntu-14.04-64-puppet-enterprise"
  	config.vm.hostname = "hello-app-vm"
  	config.ssh.forward_agent = true
    config.ssh.forward_x11 = true
	config.ssh.sudo_command = "sudo %c"
  	config.vm.synced_folder ".", "/vagrant", create: true
  	config.vm.network "forwarded_port", guest: 80, host: 8080

	config.vm.provision "puppet" do |puppet|
	    puppet.manifests_path = "puppet/manifests"
	    puppet.manifest_file  = "site.pp"
	    puppet.module_path = "puppet/modules"
	    #puppet.options = '--parser future'
	end

    config.vm.provision :docker
    config.vm.provision :docker_compose, yml: "/vagrant/docker-compose.yml", run: "always"

end