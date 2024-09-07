Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"
  config.vm.box_version = "12.20240905.1"
  config.vm.synced_folder "./", "/root/sbx-actions",
    type: "nfs",
    nfs_version: 4,
    nfs_udp: false
end
