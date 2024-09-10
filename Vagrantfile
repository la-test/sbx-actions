Vagrant.configure("2") do |config|
  config.vm.define ENV['DEPLOYMENT_TARGET']
  config.vm.hostname = ENV['DEPLOYMENT_TARGET']
  config.vm.box = "debian/bookworm64"
  config.vm.box_version = "12.20240905.1"
  config.vm.box_check_update = false

  # # Tune LibVirt/QEmu guests
  # config.vm.provider :libvirt do |domain|
  #   # No need of graphics - better use serial
  #   domain.graphics_type = "none"
  #   domain.video_type = "none"
  # end

  # Avoid the default synchronization
  config.vm.synced_folder ".", "/vagrant", disabled: true

  # Provision the repo where the deployment script expects it
  config.vm.synced_folder ".", "/root/#{ENV['DEPLOYMENT_REPO']}",
    type: "nfs",
    nfs_version: 4,
    nfs_udp: false

  config.vm.provision "shell", name: "Private key to checkout the code",
  inline: <<EOS
sudo sh -c "cat - > /root/.ssh/deploy_key" <<EOF
#{ENV['DEPLOYMENT_SSH_KEY']}
EOF
sudo chmod 0600 /root/.ssh/deploy_key
EOS

  config.vm.provision "shell", name: "Requirements for pull-mode deployment",
    path: "ansible/files/prepare-deployment",
    args: [
      "/root/#{ENV['DEPLOYMENT_REPO']}/ansible/files/update-deployment",
    ]
end
