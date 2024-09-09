# We will conveniently re-using the deployment key twice here, but only for CI purpose
$script = <<-SCRIPT
#!/usr/bin/env bash

# Configure bash behavior
set -o xtrace   # print every call to help debugging
set -o errexit  # exit on failed command
set -o nounset  # exit on undeclared variables
set -o pipefail # exit on any failed command in pipes

echo "Provide deployment private key to checkout the code"
sudo cat <<EOF > /root/.ssh/git_deploy_key
${DEPLOYMENT_SSH_KEY}
EOF
sudo chmod 0600 /root/.ssh/git_deploy_key

echo "Provide public part of the key for later"
sudo sh -c "ssh-keygen -y -f /root/.ssh/git_deploy_key -P=\"\" > /root/.ssh/git_deploy_key.pub"

echo "Create a the deployment user"
sudo adduser --disabled-password --gecos "" "${DEPLOYMENT_USER}"
sudo adduser "${DEPLOYMENT_USER}" sudo

echo "Allow the deployment user to trigger the update"
sudo sh -c "echo -n \"restrict,command=\\\"sudo update-deployment ${DEPLOYMENT_TARGET}\\\" \" \
  >> /home/${DEPLOYMENT_USER}/.ssh/authorized_keys"
sudo sh -c "cat /root/.ssh/git_deploy_key.pub \
  >> /home/${DEPLOYMENT_USER}/.ssh/authorized_keys"
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"
  config.vm.box_version = "12.20240905.1"
  config.vm.box_check_update = false
  config.vm.hostname = ENV['DEPLOYMENT_TARGET']

  # config.vm.synced_folder "./", "/root/sbx-actions",
  #   type: "nfs",
  #   nfs_version: 4,
  #   nfs_udp: false

  config.vm.provision "shell", name: "Install requirements for deployment",
    inline: "apt-get -q clean && \
      apt-get -q update && \
      apt-get -qq install -y --no-install-recommends python3-pip python3-venv && \
      apt-get -q clean"
  # Install the update-deployment script itself
  config.vm.provision "file", source: "ansible/files/update-deployment",
    destination: "/tmp/update-deployment"
  config.vm.provision "shell", name: "Move deployment script",
    inline: "sudo mv /tmp/update-deployment /usr/local/sbin/update-deployment"
  config.vm.provision "shell", name: "Change owner of deployment script",
    inline: "sudo chown root:root /usr/local/sbin/update-deployment"
  config.vm.provision "shell", name: "Allow a user to execute the deployment script",
    inline: $script,
    env: { # Pass environment variables to the guest
      "DEPLOYMENT_SSH_KEY" => ENV['DEPLOYMENT_SSH_KEY'],
      "DEPLOYMENT_USER" => ENV['DEPLOYMENT_USER'],
      "DEPLOYMENT_TARGET" => ENV['DEPLOYMENT_TARGET'],
    }
end
