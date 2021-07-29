Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu2004"

  config.vm.hostname = "singularity"

  config.vm.synced_folder "./", "/vagrant"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = 8192
    vb.cpus = 4
  end
  config.vm.provider :libvirt do |libvirt|
    libvirt.cpus = 4
    libvirt.memory = 8192
  end

  config.vm.provision "shell", inline: <<-SHELL
    # Install singularity dependencies
    apt-get update
    apt-get install -y \
    build-essential \
    libssl-dev \
    uuid-dev \
    libgpgme11-dev \
    squashfs-tools \
    libseccomp-dev \
    wget \
    pkg-config \
    git \
    cryptsetup \
    golang
    apt-get clean
    # Get singularity release
    export VERSION=3.8.0
    wget https://github.com/hpcng/singularity/releases/download/v${VERSION}/singularity-${VERSION}.tar.gz
    tar -xzf singularity-${VERSION}.tar.gz
    # Build/install singularity
    cd singularity-${VERSION}
    ./mconfig
    make -C builddir
    make -C builddir install
    cd ../
    rm -r singularity-${VERSION} singularity-${VERSION}.tar.gz
  SHELL
end
