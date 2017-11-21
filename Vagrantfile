# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

INSTALL_DEPS=<<EOF
sudo apt-get install -y python
EOF

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    config.vm.box = "ubuntu/zesty64"

    config.vm.define "home" do |home|
        home.vm.provision "shell", inline: "#{INSTALL_DEPS}"
    end

    # home-assistant
    config.vm.network "forwarded_port", guest: 8123, host: 8123
    # monit
    config.vm.network "forwarded_port", guest: 2812, host: 2812
    # HA Dashboard
    config.vm.network "forwarded_port", guest: 5050, host: 5050
    # Sonos HTTP API
    config.vm.network "forwarded_port", guest: 5005, host: 5005
    # Roofcam web
    config.vm.network "forwarded_port", guest: 1234, host: 1234
    # Uchiwa sensu dashboard
    config.vm.network "forwarded_port", guest: 3000, host: 3000

    config.vm.provider "virtualbox" do |v|
        v.memory = 1024
        v.cpus = 2
        # https://joeshaw.org/terrible-vagrant-virtualbox-performance-on-mac-os-x/
        v.customize [
            "storagectl", :id,
            "--name", "IDE",
            "--hostiocache", "on"
        ]
    end

    if Vagrant.has_plugin?("vagrant-cachier")
        config.cache.scope = :box
    end

end
