# PyTorch GAN Zoo

This example builds a singularity container for [Facebook Research's PyTorch GAN
Zoo](https://github.com/facebookresearch/pytorch_GAN_zoo).

The singularity container will allow you to call all the scripts from the
project and includes are requirements. The container supports CUDA versions
10.1, 10.2 and 11.1 on the host.

## Building

To build the singularity container use the build script in this directory.

```bash
./build.sh
```

This script will try to use singularities [fakeroot
support](https://sylabs.io/guides/3.5/user-guide/fakeroot.html) if you run as a
non-root user. If this is not supported on your system you can run the script as
root.

When the script is finished you will find the container (`pytorch_GAN_zoo.sif`)
in you current working directory.

## Usage

The scripts from [PyTorch GAN
Zoo](https://github.com/facebookresearch/pytorch_GAN_zoo) can be called with
`singularity exec pytorch_GAN_zoo.sif <script name>`, for example

```bash
singularity exec pytorch_GAN_zoo.sif eval.py
```

Any flags or command line arguments can be declared after the script name.

When training, you will need to supply the `--nv` flag to singularity so that
the host GPU may be used. You will also need to select a singularity app, using
the `--app` flag to select the appropriate CUDA version. The available apps are
`cu101`, `cu102`, and `cu111` for CUDA 10.1, 10.2 and 11.1 respectively.

For example, to pre-process the dtd dataset and train a PGAN model on a host
with CUDA 10.2 you could run the following commands.

```bash
singularity exec pytorch_GAN_zoo.sif datasets.py dtd <path to dtd dataset>/images/
singularity exec pytorch_GAN_zoo.sif --nv --app cu102 train.py PGAN -c config_dtd.json --restart --no_vis -n dtd
```

### Models

Here are examples showing how to use this container to train a PGAN model using
the DTD and CIFAR-10 datasets.

See the [datasets directory](../../datasets/) for scripts to fetch these
datasets.

In each example the `--restart` flag is used so that checkpoints are
periodically written during the training. The `--no_vis` flag is used to disable
visdom visualisations.

#### DTD

The DTD dataset requires no preprocessing, so the datasets script simply creates
a configuration file.

```bash
python datasets.py dtd <path to dtd>/images
python train.py PGAN -c config_dtd.json --restart --no_vis -n dtd
```

Where `<path to dtd>` is the path of the directory extracted from the dtd
archive. This directory contains the subdirectories iamges, imdb and labels.

#### CIFAR-10

When training a model with the CIFAR-10 dataset some preprocessing is required.
A processed dataset will be written to a directory delcared using the `-o` flag,
`cifar-10` n this example.

```bash
python datasets.py cifar10 <path to cifar-10> -o cifar10
python train.py -c config_cifar10.json --restart --no_vis -n cifar10
```

Where `<path to cifar-10>` is the path of the directory containing the pickle
files named `data_batch_{1..5}`.
