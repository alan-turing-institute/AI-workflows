# AI-workflows

A collections of portable, real-world AI workflows for testing and benchmarking

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
