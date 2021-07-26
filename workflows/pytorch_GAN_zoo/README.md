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

This script will try to use singularities fakeroot support if you run as a
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

For example, to pre-process the celeba dataset and train a PGAN model on a host
with CUDA 10.2 you could run the following commands.

```bash
singularity exec pytorch_GAN_zoo.sif datasets.py celeba_cropped <path to celeba dataset>/img_align_celeba/ -o celeba
singularity exec pytorch_GAN_zoo.sif --nv --app cu102 train.py PGAN -c config_celeba_cropped.json --restart -n celeba_cropped
```
