Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"
  #config.vm.provision "shell", inline: "sudo apt -y install nfs-common"
  config.vm.synced_folder "./", "/root/sbx-actions",
    type: "nfs",
    nfs_udp: "false"
end
