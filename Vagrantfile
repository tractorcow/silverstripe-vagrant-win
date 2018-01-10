# -*- mode: ruby -*-
# vi: set ft=ruby :

# Failed boxes:
# - config.vm.box = "mwrock/Windows2016" # NO IIS

Vagrant.configure("2") do |config|
  config.vm.box = "gusztavvargadr/w16s-iis"
  config.vm.box_version = "0.8.0"

  # I can browse this server on localhost:9090/Sites/<foldername>/
  config.vm.network "forwarded_port", guest: 80, host: 9090, host_ip: "127.0.0.1"

  # Enable WinRM
  config.vm.network :forwarded_port,
    guest: 5985,
    host: 5985,
    id: "winrm",
    auto_correct: true

  # Share localhost webroot
  config.vm.synced_folder "./Sites",
    "/inetpub/wwwroot/Sites",
    :create => true,
    :mount_options => [
      "dmode=755",
      "fmode=755"
    ]

  # Increase boot timeout
  config.vm.boot_timeout = 3600

  config.vm.communicator = "winrm"
  config.winrm.username = "vagrant"
  config.winrm.password = "vagrant"

end
