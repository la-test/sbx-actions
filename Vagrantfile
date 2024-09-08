Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"
  config.vm.box_version = "12.20240905.1"
  config.vm.box_check_update = false

  config.vm.synced_folder "./", "/root/sbx-actions",
    type: "nfs",
    nfs_version: 4,
    nfs_udp: false

  config.vm.provision "file", source: "ansible/files/update-deployment", destination: "/usr/local/sbin/update-deployment"
  #config.vm.provision "shell", inline: "sudo mkdir /root/.ssh && sudo chmod 0700 /root/.ssh"
  # Install required packages to install Ansible
  RUN INSTALL_PKGS="" && \

  config.vm.provision "shell", inline: "apt-get -q clean && \
    apt-get -q update && \
    apt-get install -y python3-pip python3-venv && \
    apt-get -q clean"
  config.vm.provision "shell", inline: "sudo echo -n \"#{ENV['SSH_DEPLOYMENT_KEY']}\" \
    > /root/.ssh/id_ed25519 && sudo chmod 0600 /root/.ssh/id_ed25519"
  config.vm.provision "shell", inline: "sudo echo -n \"restrict,command=\"sudo \
    update-deployment base-local #{ENV['SSH_DEPLOYMENT_KEY_PUB']}\" >> /root/.ssh/authorized_keys"
end
