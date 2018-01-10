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
  # @todo - I can't figure out how to make these writable to PHP
  # You can work around this by copying your site out of
  # the share to c:\inetpub\wwwroot directly
  config.vm.synced_folder "./Sites",
    "/inetpub/wwwroot/Sites",
    :create => true,
    :mount_options => [
      "dmode=777",
      "fmode=777"
    ]

  # Increase boot timeout
  config.vm.boot_timeout = 3600

  config.vm.communicator = "winrm"
  config.winrm.username = "vagrant"
  config.winrm.password = "vagrant"

  # Run the install via powershell
  # reference: https://github.com/StefanScherer/docker-windows-box/tree/master/windows10/scripts
  config.vm.provision "shell", path: "scripts/install-chocolatey.ps1"
  config.vm.provision "shell", path: "scripts/install-iis.ps1"
  config.vm.provision "shell", path: "scripts/install-php.ps1"
end
