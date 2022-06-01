# PyTorch GAN Zoo

This workflow containerises [Facebook Research's PyTorch GAN
Zoo](https://github.com/facebookresearch/pytorch_GAN_zoo). That code is a
toolbox for training a selection of [generative adversarial
networks](https://en.wikipedia.org/wiki/Generative_adversarial_network) on
popular image datasets.

Once a model has been trained it can be used to generate new images. For
example, after training a model on pictures of celebrities a set of 'fake'
celebrity pictures can be created.

The container supports CUDA version 11.1 on the host.

## Building

To build the singularity container use the build script in this directory.

```bash
./build.sh
```

This script will try to use singularities [fakeroot
support](https://sylabs.io/guides/main/user-guide/fakeroot.html) if you run as a
non-root user. If this is not supported on your system you can run the script as
root.

When the script is finished you will find the container (`pytorch_GAN_zoo.sif`)
in your current working directory.

## Usage

The scripts from [PyTorch GAN
Zoo](https://github.com/facebookresearch/pytorch_GAN_zoo) can be called with
`singularity exec pytorch_GAN_zoo.sif <script_name>`, for example

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

## Example Workflow

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
singularity exec pytorch_GAN_zoo.sif datasets.py dtd dtd/images
```

### CIFAR-10

When training a model with the CIFAR-10 dataset some preprocessing is required.

```bash
singularity exec pytorch_GAN_zoo.sif datasets.py cifar10 cifar-10-batches-py -o cifar10
```

A processed dataset will be written to a directory called `cifar-10` and a
configuration file named `config_cifar10.json` will be written.

## Training

Here are examples of training PGAN models using the three datasets as processed
and configured above.

Note that training these models takes approximately six days on a single Nvidia
V100.

In each example the `--restart` flag is used so that checkpoints are
periodically written during the training. The `--no_vis` flag stops the training
script from trying to send information to a
[visdom](https://github.com/fossasia/visdom/) server.

These examples assume that the configuration files are named as those created
above.

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

Each of these examples will write checkpoint and final weights to
`output_networks/<model_name>` where `<model_name>` is the name you declare
using the `-n` flag.

## Image generation

Using a trained model, a set of sample images can be generated using the
`eval.py` script.

The syntax for this is,

```bash
singularity exec --nv pytorch_GAN_zoo.sif eval.py visualization --np_vis -d output_networks -n <model_name> -m PGAN --save_dataset ./<output_directory> --size_dataset <data_set_size>
```

`<model_name>` is the same value as you used when training. `<data_set_size>`
specifies the number of images to generate. The images will be saved in the
`<output_directory>` directory.

For example, to generate 1000 images of fake celebrities using a model trained
as above,

```bash
singularity exec --nv pytorch_GAN_zoo.sif eval.py visualization --np_vis -d output_networks -n celeba_cropped -m PGAN --save_dataset ./fake_celebs --size_dataset 1000
```

For data sets with categories, such as DTD and CIFAR-10, images can be generated
for a particular category. To see the available categories use the
`--showLabels` flag. For example with CIFAR-10,

```bash
$ singularity exec --nv pytorch_GAN_zoo.sif eval.py visualization --np_vis -d output_networks -n cifar10 -m PGAN --showLabels
...
  --Main MAIN           ['automobile', 'bird', 'truck', 'airplane', 'cat',
                          'horse', 'ship', 'frog', 'deer', 'dog']
...
```

A set of generated 'frog' images can then be saved by using the category flag
`--Main` and the label `frog`,

```bash
singularity exec --nv pytorch_GAN_zoo.sif eval.py visualization --np_vis -d output_networks -n cifar10 -m PGAN --Main frog --save_dataset ./frogs --size_dataset 100
```

## Running on HPC

If you want to do repeated training runs (for example benchmarking) you can use
the `-n` flag to set the output directory. This will prevent repeat runs of the
same model and dataset from overwriting each other.

The configuration files generated using `datasets.py` include relative paths to
the data sets. The relative location of the datasets must therefore be the same
when training.

On HPC you will most likely want to move the datasets to take advantage of
high-speed scratch disks. It is therefore most convenient to copy the
configuration file and dataset to scratch space, bind that space and use `--pwd`
flag to change to that directory inside the container.

The [`batch_scripts`](./batch_scripts) directory contains template Slurm batch
scripts for training models on the [CelebA](batch_scripts/train_celeba.sh),
[CIFAR-10](batch_scripts/train_cifar10.sh) and [DTD](batch_scripts/train_dtd.sh)
datasets. These templates assume that data directories and configuration files
are named as those created above. They demonstrate the advice for running
on HPC explained [here](../../docs/hpc.md)

To submit a job use `sbatch` with the `--array` flag. For example

```bash
sbatch --array=1 train_celeba.sh
```
