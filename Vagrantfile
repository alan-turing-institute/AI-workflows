Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu2204"

  config.vm.hostname = "apptainer"

  config.vm.synced_folder "./", "/vagrant"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = 8192
    vb.cpus = 4
  end
  config.vm.provider "libvirt" do |libvirt, override|
    libvirt.cpus = 4
    libvirt.memory = 8192
    override.vm.synced_folder "./", "/vagrant", type: "nfs", nfs_udp: false
  end

  config.vm.provision "shell", inline: <<-SHELL
    export VERSION=1.0.2
    wget https://github.com/apptainer/apptainer/releases/download/v${VERSION}/apptainer_${VERSION}_amd64.deb
    apt-get install -y ./apptainer_${VERSION}_amd64.deb
    rm -r apptainer_${VERSION}_amd64.deb
  SHELL
end
