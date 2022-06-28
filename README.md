# AI-workflows

A collections of portable, real-world AI workflows for testing and benchmarking

## Workflows

- [Pytorch GAN zoo](./workflows/pytorch_GAN_zoo/)
- [3D Very Deep VAE](./workflows/3d_very_deep_vae/)

## Running Workflows on HPC

[hpc.md](./hpc.md) has advice on running the workflows on HPC systems. Each
workflow also contains template Slurm batch scripts.

## Using Vagrant

The included Vagrantfile can be used to build the examples if your system does
not support singularity or if you would prefer not to install singularity on
your host. The Vagrantfile has support for the VirtualBox and libvirt providers.

To create the virtual machine run

```bash
vagrant up --provider <provider>
```

for example

```bash
vagrant up --provider libvirt
```

When this is finished, you can connect to the virtualmachine in the normal way

```bash
vagrant ssh
```

and will find this project mounted at `/vagrant/`

### Local testing with WSL2 and VirtualBox
If using Windows Subsystem for Linux on a host Windows machine, there are two minor requirements in order to provision with VirtualBox. The first is to create a local port forward to allow ssh to `0.0.0.0` over `localhost`. This can be achieved with a handy plugin: [VirtualboxWSL2](https://github.com/Karandash8/virtualbox_WSL2), installed with

```bash
vagrant plugin install virtualbox_WSL2
```

Second, a [caveat](https://github.com/hashicorp/vagrant/issues/10576) of file system support. For synced folders (where project files shall be mounted at `/vagrant/`) vagrant will expect to find a DrvFs (`/mnt/c/`) file system. The project file location can be updated in the [Vagrantfile](.Vagrantfile) or rather move the repo to a windows mount, e.g. `/mnt/c/`, `/mnt/d`, etc.