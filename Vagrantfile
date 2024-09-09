Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"
  config.vm.box_version = "12.20240905.1"
  config.vm.box_check_update = false
  config.vm.hostname = ENV['DEPLOYMENT_HOST']

  # config.vm.synced_folder "./", "/root/sbx-actions",
  #   type: "nfs",
  #   nfs_version: 4,
  #   nfs_udp: false

  # Install the system packages required by the deployment script
  config.vm.provision "shell", inline: "apt-get -q clean && \
    apt-get -q update && \
    apt-get -q install -y --no-install-recommends python3-pip python3-venv && \
    apt-get -q clean"
  # Install the update-deployment script itself
  config.vm.provision "file", source: "ansible/files/update-deployment",
    destination: "/tmp/update-deployment"
  config.vm.provision "shell", name: "Move deployment script",
    inline: "sudo mv /tmp/update-deployment /usr/local/sbin/update-deployment"
  config.vm.provision "shell", name: "Change owner of deployment script",
    inline: "sudo chown root:root /usr/local/sbin/update-deployment"
  config.vm.provision "shell", name: "Provide deployment key to checkout the code",
    inline: "sudo sh -c 'echo -n \"#{ENV['DEPLOYMENT_SSH_KEY']}\" \
      > /root/.ssh/git_deploy_key' && sudo chmod 0600 /root/.ssh/git_deploy_key"
  config.vm.provision "shell", inline: "sudo cat /root/.ssh/git_deploy_key"
  config.vm.provision "shell", name: "Provide public part of the key for later",
    inline: "sudo sh -c 'ssh-keygen -y -f /root/.ssh/git_deploy_key -P=\'\' \
    > /root/.ssh/git_deploy_key.pub'"
  # We will conveniently re-using the deployment key twice here, but only for CI
  config.vm.provision "shell", name: "Create a the deployment user",
    inline: "sudo adduser #{ENV['DEPLOYMENT_USER']} \
      && sudo adduser #{ENV['DEPLOYMENT_USER']} sudo"
  config.vm.provision "shell", name: "Allow the deployment user to trigger the update",
    inline: "sudo sh -c 'echo -n \'restrict,command=\"sudo update-deployment \
      #{ENV['DEPLOYMENT_HOST']}\" \' >> /home/#{ENV['DEPLOYMENT_USER']}/.ssh/authorized_keys'"
  config.vm.provision "shell", name: "Re-using the deployment key used to checkout",
    inline: "sudo sh -c 'cat /root/.ssh/git_deploy_key.pub \
      >> /home/#{ENV['DEPLOYMENT_USER']}/.ssh/authorized_keys'"
end
