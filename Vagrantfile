# We will conveniently re-using the deployment key twice here, but only for CI purpose
$script = <<-SCRIPT
#!/usr/bin/env bash

# Configure bash behavior
#set -o xtrace   # print every call to help debugging
set -o errexit  # exit on failed command
set -o nounset  # exit on undeclared variables
set -o pipefail # exit on any failed command in pipes

echo "Ensure the required system packages are installed for the deployment"
export DEBIAN_FRONTEND=noninteractive
apt-get -q update > /dev/null
apt-get -q install -y --no-install-recommends git python3-pip python3-venv > /dev/null
apt-get -q clean

echo "Install the deployment script itself"
sudo cp -a "/root/${DEPLOYMENT_REPO}/ansible/files/update-deployment" /usr/local/sbin/update-deployment
sudo chmod +x /usr/local/sbin/update-deployment

echo "Provision deployment private key to checkout the code"
deploy_key="/root/.ssh/deploy_key"
sudo sh -c "cat - > \"${deploy_key}\"" <<EOF
${DEPLOYMENT_SSH_KEY}
EOF
sudo chmod 0600 "${deploy_key}"

echo "Provide public part of the key for later"
sudo sh -c "ssh-keygen -y -f \"${deploy_key}\" -P=\"\" > \"${deploy_key}.pub\""

echo "Create a the deployment user"
sudo adduser --disabled-password --gecos "" "${DEPLOYMENT_USER}"
sudo adduser "${DEPLOYMENT_USER}" sudo
sudo sh -c "cat - > /etc/sudoers.d/update-deployment" <<EOF
${DEPLOYMENT_USER} ALL=(ALL) NOPASSWD: ALL
EOF

echo "Allow the deployment user to trigger the update"
sudo -u ${DEPLOYMENT_USER} mkdir /home/${DEPLOYMENT_USER}/.ssh
sudo -u ${DEPLOYMENT_USER} touch /home/${DEPLOYMENT_USER}/.ssh/authorized_keys
sudo chmod -R go-rwx /home/${DEPLOYMENT_USER}/.ssh
tr -d '\n' <<EOF | sudo sh -c "cat - \"${deploy_key}.pub\" \
>> /home/${DEPLOYMENT_USER}/.ssh/authorized_keys"
restrict,command="sudo update-deployment ${DEPLOYMENT_TARGET}" 
EOF
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.define ENV['DEPLOYMENT_TARGET']
  config.vm.box = "debian/bookworm64"
  config.vm.box_version = "12.20240905.1"
  config.vm.box_check_update = false

  # # Tune LibVirt/QEmu guests
  # config.vm.provider :libvirt do |domain|
  #   # No need of graphics - better use serial
  #   domain.graphics_type = "none"
  #   domain.video_type = "none"
  # end

  # Provision the repo where the deployment script expects it
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.synced_folder ".", "/root/#{ENV['DEPLOYMENT_REPO']}",
    type: "nfs",
    nfs_version: 4,
    nfs_udp: false

  config.vm.provision "shell", name: "Allow a user to execute the deployment script",
    inline: $script,
    env: { # Pass environment variables to the guest
      "DEPLOYMENT_SSH_KEY" => ENV['DEPLOYMENT_SSH_KEY'],
      "DEPLOYMENT_USER" => ENV['DEPLOYMENT_USER'],
      "DEPLOYMENT_TARGET" => ENV['DEPLOYMENT_TARGET'],
      "DEPLOYMENT_REPO" => ENV['DEPLOYMENT_REPO'],
    }
end
