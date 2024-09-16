#!/usr/bin/env bash

# This script prepares the requirements for the update-deployment script
# It may be used by Ansible or other provisioners such as Vagrant

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

echo "Ensure that the packages required for the deployment are installed"
export DEBIAN_FRONTEND=noninteractive
apt-get -q update > /dev/null
apt-get -q install -y --no-install-recommends git python3-pip python3-venv > /dev/null
apt-get -q clean

echo "Install the deployment script itself"
cp -a "${deploy_script}" /usr/local/sbin/update-deployment
chmod +x /usr/local/sbin/update-deployment

echo "Generate public part of the key if needed"
test -f "${deploy_key}.pub" \
|| ssh-keygen -y -f "${deploy_key}" -P "" > "${deploy_key}.pub"

echo "Create a the deployment user"
adduser --disabled-password --gecos "" "${deploy_user}"
adduser "${deploy_user}" sudo
cat - > /etc/sudoers.d/update-deployment <<EOF
${deploy_user} ALL=(ALL) NOPASSWD: ALL
EOF

echo "Allow the deployment user to trigger the update"
sudo -u ${deploy_user} mkdir /home/${deploy_user}/.ssh
sudo -u ${deploy_user} touch /home/${deploy_user}/.ssh/authorized_keys
chmod -R go-rwx /home/${deploy_user}/.ssh
tr -d '\n' <<EOF | cat - "${deploy_key}.pub" \
>> /home/${deploy_user}/.ssh/authorized_keys
restrict,command="sudo update-deployment ${deploy_target} fast" 
EOF
# DON NOT remove the trailing space above!
