# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

INSTALL_DEPS=<<EOF
sudo apt-get install -y python
EOF

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    config.vm.box = "ubuntu/zesty64"

    config.vm.define "dev" do |dev|
        dev.vm.provision "shell", inline: "#{INSTALL_DEPS}"
    end

    config.vm.network "forwarded_port", guest: 8123, host: 8123


    if Vagrant.has_plugin?("vagrant-cachier")
        config.cache.scope = :box
    end

end
