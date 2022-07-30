# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
  config.vm.box = "esselius/nixos"
  config.vm.synced_folder ".", "/vagrant", disabled: false, rsync__exclude: ['./result', "nixos.qcow2"]
end
