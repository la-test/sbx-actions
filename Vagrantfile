# We will conveniently re-using the deployment key twice here, but only for CI purpose
$prepare_deployment = <<-EOS
#!/usr/bin/env bash

# Configure bash behavior
#set -o xtrace   # print every call to help debugging
set -o errexit  # exit on failed command
set -o nounset  # exit on undeclared variables
set -o pipefail # exit on any failed command in pipes

# Read the arguments
deploy_script=${1?"Unknown source"}
deploy_target=${2-"$(hostname)"}
deploy_user=${3-"bot-cd"}
deploy_key=${4-"/root/.ssh/deploy_key"}

echo "Ensure the required system packages are installed for the deployment"
export DEBIAN_FRONTEND=noninteractive
apt-get -q update > /dev/null
apt-get -q install -y --no-install-recommends git python3-pip python3-venv > /dev/null
apt-get -q clean

echo "Install the deployment script itself"
sudo cp -a "${deploy_script}" /usr/local/sbin/update-deployment
sudo chmod +x /usr/local/sbin/update-deployment

echo "Generate public part of the key if needed"
sudo sh -c "test -f \"${deploy_key}.pub\" \
|| ssh-keygen -y -f \"${deploy_key}\" -P=\"\" > \"${deploy_key}.pub\""

echo "Create a the deployment user"
sudo adduser --disabled-password --gecos "" "${deploy_user}"
sudo adduser "${deploy_user}" sudo
sudo sh -c "cat - > /etc/sudoers.d/update-deployment" <<EOF
${deploy_user} ALL=(ALL) NOPASSWD: ALL
EOF

echo "Allow the deployment user to trigger the update"
sudo -u ${deploy_user} mkdir /home/${deploy_user}/.ssh
sudo -u ${deploy_user} touch /home/${deploy_user}/.ssh/authorized_keys
sudo chmod -R go-rwx /home/${deploy_user}/.ssh
tr -d '\n' <<EOF | sudo sh -c "cat - \"${deploy_key}.pub\" \
>> /home/${deploy_user}/.ssh/authorized_keys"
restrict,command="sudo update-deployment ${deploy_target}" 
EOF
EOS

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
set -o xtrace
sudo sh -c "cat - > /root/.ssh/deploy_key" <<EOF
#{ENV['DEPLOYMENT_SSH_KEY']}
EOF
sudo chmod 0600 /root/.ssh/deploy_key
EOS

  config.vm.provision "shell", name: "Requirements for pull-mode deployment",
    inline: $prepare_deployment,
    args: [
      "/root/#{ENV['DEPLOYMENT_REPO']}/ansible/files/update-deployment",
    ]
end
