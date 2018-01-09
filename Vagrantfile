# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "Svpernova09/Windows7-php7dev"

  # I can browse this server on localhost:9090
  config.vm.network "forwarded_port", guest: 80, host: 9090, host_ip: "127.0.0.1"

  # Enable RDP
  config.vm.network :forwarded_port,
    host: 33389,
    guest: 3389,
    id: "rdp",
    auto_correct: true

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share localhost webroot
  config.vm.synced_folder "./Sites", "/Sites"
end
