# PyTorch GAN Zoo

This example builds a singularity container for [Facebook Research's PyTorch GAN
Zoo](https://github.com/facebookresearch/pytorch_GAN_zoo).

The singularity container will allow you to call all the scripts from the
project and includes are requirements. The container supports CUDA version 11.1
on the host.

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
in your current working directory.

## Usage

The scripts from [PyTorch GAN
Zoo](https://github.com/facebookresearch/pytorch_GAN_zoo) can be called with
`singularity exec pytorch_GAN_zoo.sif <script name>`, for example

```bash
singularity exec pytorch_GAN_zoo.sif train.py
```

Any flags or command line arguments can be declared after the script name.

For many scripts, you will need to supply the `--nv` flag to singularity so that
the host GPU may be used.

## Multiple GPUs

PyTorch GAN zoo natively supports [parallelisation across multiple
GPUs](https://github.com/facebookresearch/pytorch_GAN_zoo/issues/57). The
devices to use can be selected using the `CUDA_VISIBLE_DEVICES` environment
variable. CUDA compatible GPUs are numbered from zero. For example, to use the
first and third CUDA accelerators you would set `CUDA_VISIBLE_DEVICES=0,2`

To pass this environment variable to singularity the `--env-file` flag must be
used as [passing environment variables with commas is not supported by the
`--env` flag](https://github.com/apptainer/singularity/issues/6088).

```bash
echo 'CUDA_VISIBLE_DEVICES=0,1' > env.txt
singularity exec --env-file env.txt pytorch_GAN_zoo.sif ...
```

## Fetching Datasets

The container includes a convenience script for fetching datasets.

Each dataset can be fetched using,

```bash
singularity exec pytorch_GAN_zoo.sif get_data <dataset>
```

| `<dataset>` | description                                                                           |
|-------------|---------------------------------------------------------------------------------------|
| `dtd`       | [5,640 texture images in 47 categories](https://www.robots.ox.ac.uk/~vgg/data/dtd/)   |
| `cifar10`   | [60,000 images of objects in 10 classes](https://www.cs.toronto.edu/~kriz/cifar.html) |

Both datasets can be fetch with the following commands,

```bash
singularity exec pytorch_GAN_zoo.sif get_data dtd
singularity exec pytorch_GAN_zoo.sif get_data cifar10
```

[CelebA](http://mmlab.ie.cuhk.edu.hk/projects/CelebA.html) is a dataset of more
than 200,000 images of celebrities.  Downloading this dataset is more difficult
to automate. The dataset can be downloaded using a browser
[here](https://drive.google.com/file/d/0B7EVK8r0v71pZjFTYXZWM3FlRnM/view?resourcekey=0-dYn9z10tMJOBAkviAcfdyQ).

## Story

Here are examples showing how to use this container to train a
[PGAN](https://arxiv.org/pdf/1710.10196.pdf) model using the CelebA, DTD and
CIFAR-10 datasets and visualise the results.

You can also use the [DCGAN](https://arxiv.org/pdf/1511.06434.pdf) model by
passing `-m DCGAN` to `datasets.py`, `train.py` and `eval.py`. If you do not
specify the model with `-m` PGAN will be used.

## Preprocessing

Some of the datasets require preprocessing before they can be used for training.
The commands in this section assume the datasets are located in directories
named as the `get_data` commands above would do, with the exception of CelebA.

### CelebA

The CelebA dataset requires some preprocessing to crop and orientate the
images.

Extract the dataset,

```bash
unzip img_align_celeba.zip
```

Use the `datasets.py` script to preprocess the images,

```bash
singularity exec pytorch_GAN_zoo.sif datasets.py celeba_cropped <path_to_celeba>/img_align_celeba/ -o celeba_cropped
```

This command will save the modified dataset in a directory called
`celeba_cropped` and create a training configuration file `config_celeba_cropped.json`.

### DTD

The DTD dataset requires no preprocessing, so the datasets script simply creates
a configuration file, `config_dtd.json`,

```bash
singularity exec --nv pytorch_GAN_zoo.sif datasets.py dtd dtd/images
```

### CIFAR-10

When training a model with the CIFAR-10 dataset some preprocessing is required.

```bash
singularity exec --nv pytorch_GAN_zoo.sif datasets.py cifar10 cifar-10-batches-py -o cifar10
```
A processed dataset will be written to a directory called `cifar-10` and a
configuration file named `config_cifar10.json` will be written.

## Training

Here are examples of training PGAN models using the three datasets as processed
and configured above.

In each example the `--restart` flag is used so that checkpoints are
periodically written during the training. The `--no_vis` flag stops the training
script from trying to send information to a
[visdom](https://github.com/fossasia/visdom/) server.

Note that training these models takes approximately six days on a single Nvidia
V100.

Each of these examples will write checkpoint and final weights to
`output_networks/<model_name>` where `<model_name>` is the name you declare
using the `-n` flag.

### CelebA

```bash
singularity exec --nv pytorch_GAN_zoo.sif train.py PGAN -c config_celeba_cropped.json --restart --no_vis -n celeba_cropped
```

### DTD

```bash
singularity exec --nv pytorch_GAN_zoo.sif train.py PGAN -c config_dtd.json --restart --no_vis -n dtd
```

### CIFAR-10

```bash
singularity exec --nv pytorch_GAN_zoo.sif train.py -c config_cifar10.json --restart --no_vis -n cifar10
```

