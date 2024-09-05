Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"
  config.vm.network 'private_network', ip: '172.28.128.2'
  config.vm.synced_folder "./", "/root/sbx-actions"
end
