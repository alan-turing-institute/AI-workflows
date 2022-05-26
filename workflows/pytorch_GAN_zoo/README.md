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
[here](https://drive.google.com/file/d/0B7EVK8r0v71pZjFTYXZWM3FlRnM/view?resourcekey=0-dYn9z10tMJOBAkviAcfdyQ)

## Story

Here are examples showing how to use this container to train a
[PGAN](https://arxiv.org/pdf/1710.10196.pdf) model using the CelebA, DTD and
CIFAR-10 datasets and visualise the results.

You can also use the [DCGAN](https://arxiv.org/pdf/1511.06434.pdf) model by
passing `-m DCGAN` to `datasets.py`, `train.py` and `eval.py`. If you do not
specify the model with `-m` PGAN will be used.

## Preprocessing

Some of the datasets require preprocessing before they can be used for training.

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

## Training

In each example the `--restart` flag is used so that checkpoints are
periodically written during the training. The `--no_vis` flag is used to disable
visdom visualisations.

### CelebA

The [CelebA](http://mmlab.ie.cuhk.edu.hk/projects/CelebA.html) data set can be
[downloaded from a public Google Drive repository](https://drive.google.com/file/d/0B7EVK8r0v71pZjFTYXZWM3FlRnM/view?usp=sharing&resourcekey=0-dYn9z10tMJOBAkviAcfdyQ)

Extract the dataset,

```bash
unzip img_align_celeba.zip
```

The CelebA dataset requires some preprocessing to crop and orientate the
images.

```bash
singularity exec --nv pytorch_GAN_zoo.sif datasets.py celeba_cropped <path_to_celeba>/img_align_celeba/ -o celeba_cropped
singularity exec --nv pytorch_GAN_zoo.sif train.py PGAN -c config_celeba_cropped.json --restart --no_vis -n celeba_cropped
```

### DTD

The DTD dataset requires no preprocessing, so the datasets script simply creates
a configuration file.

```bash
singularity exec --nv pytorch_GAN_zoo.sif datasets.py dtd <path to dtd>/images
singularity exec --nv pytorch_GAN_zoo.sif train.py PGAN -c config_dtd.json --restart --no_vis -n dtd
```

Where `<path to dtd>` is the path of the directory extracted from the dtd
archive. This directory contains the subdirectories iamges, imdb and labels.

### CIFAR-10

When training a model with the CIFAR-10 dataset some preprocessing is required.
A processed dataset will be written to a directory delcared using the `-o` flag,
`cifar-10` n this example.

```bash
singularity exec --nv pytorch_GAN_zoo.sif datasets.py cifar10 <path to cifar-10> -o cifar10
singularity exec --nv pytorch_GAN_zoo.sif train.py -c config_cifar10.json --restart --no_vis -n cifar10
```

Where `<path to cifar-10>` is the path of the directory containing the pickle
files named `data_batch_{1..5}`.
