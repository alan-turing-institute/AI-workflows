Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu2004"

  config.vm.hostname = "apptainer"

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
    # Apptainer installation instructions
    # https://github.com/apptainer/apptainer/blob/main/INSTALL.md
    #
    # Install Apptainer dependencies
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
    cryptsetup
    apt-get clean
    #
    # Install GO
    export GOVERSION=1.17.7 OS=linux ARCH=amd64
    wget -O go${GOVERSION}.${OS}-${ARCH}.tar.gz https://dl.google.com/go/go${GOVERSION}.${OS}-${ARCH}.tar.gz
    tar -C /opt -xzf go${GOVERSION}.${OS}-${ARCH}.tar.gz
    rm go${GOVERSION}.${OS}-${ARCH}.tar.gz
    export PATH=$PATH:/opt/go/bin
    #
    # Get Apptainer release
    export VERSION=1.0.0
    wget https://github.com/apptainer/apptainer/releases/download/v${VERSION}/apptainer-${VERSION}.tar.gz
    tar -xzf apptainer-${VERSION}.tar.gz
    #
    # Build/install Apptainer
    cd apptainer-${VERSION}
    ./mconfig
    make -C builddir
    make -C builddir install
    cd ../
    rm -r apptainer-${VERSION} apptainer-${VERSION}.tar.gz
  SHELL
end
