# -*- mode: ruby -*-
# vi: set ft=ruby :

host_name = ENV.has_key?('DEPLOYMENT_TARGET') ? ENV['DEPLOYMENT_TARGET'] : 'base-local'
repo_name = ENV.has_key?('DEPLOYMENT_REPO') ? ENV['DEPLOYMENT_REPO'] : abort("Repo is undefined!")
ssh_key = ENV.has_key?('DEPLOYMENT_SSH_KEY') ? ENV['DEPLOYMENT_SSH_KEY'] : abort("SSH key is undefined!")

# Get a dedicated LibVirt pool name or use default one
pool_name = ENV.has_key?('POOL_NAME') ? ENV['POOL_NAME'] : 'default'
# For instance, one could create such pool beforehand as follows:
#   export POOL_NAME=morph_local_$(id -un)
#   POOL_PATH="/path/to/your/storage"
#   mkdir -p "${POOL_PATH}"
#   sudo virsh pool-define-as ${POOL_NAME} --type dir --target "${POOL_PATH}"
#   sudo virsh pool-autostart ${POOL_NAME}
#   sudo virsh pool-start ${POOL_NAME}

Vagrant.configure("2") do |config|
  config.vm.define host_name
  config.vm.hostname = host_name
  config.vm.box = "debian/bookworm64"
  config.vm.box_version = "12.20240905.1"
  config.vm.box_check_update = false

  # Tune LibVirt/QEmu guests
  config.vm.provider :libvirt do |domain|
    # The default of one CPU should work
    # Increase to speed up boot/push/deploy
    domain.cpus = 2
    # The default memory size should work in most case
    domain.memory = 2048

    # Using a specific pool helps to manage the disk space
    domain.storage_pool_name = pool_name
    domain.snapshot_pool_name = pool_name

    # No need of graphics - better use serial
    # domain.graphics_type = "none"
    # domain.video_type = "none"
  end

  # Avoid the default synchronization
  config.vm.synced_folder ".", "/vagrant", disabled: true

  # Provision the repo where the deployment script expects it
  config.vm.synced_folder ".", "/root/#{repo_name}",
    type: "nfs",
    nfs_version: 4,
    nfs_udp: false

  config.vm.provision "shell", name: "Private key to checkout the code",
  inline: <<EOS
sudo test -d /root/.ssh || { sudo mkdir /root/.ssh; sudo chmod 0700 /root/.ssh; }
sudo sh -c "cat - > /root/.ssh/deploy_key" <<EOF
#{ssh_key}
EOF
sudo chmod 0600 /root/.ssh/deploy_key
EOS

  config.vm.provision "shell", name: "Requirements for pull-mode deployment",
    path: "helpers/bootstrap-deployment.sh",
    args: [
      "/root/#{repo_name}/ansible/files/update-deployment",
    ]
end
