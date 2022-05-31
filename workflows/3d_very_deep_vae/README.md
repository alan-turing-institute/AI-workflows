# 3D Very Deep VAE

This workflow containerises the [3D Very Deep
VAE](https://github.com/high-dimensional/3d_very_deep_vae) package. That project
involved training variational autoencoder models to generate three-dimensional
images. Specifically, models have been trained on neuroimaging data and used to
generate synthetic, volumetric brain images.

The container image defined here can be used to generate a synthetic data set,
train a model and assess that model.

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

The scripts from the [3D Very Deep VAE repository scripts
directory](https://github.com/high-dimensional/3d_very_deep_vae/tree/main/scripts)
can be called with `singularity exec 3d_very_deep_vae.sif <script_name>` for
example

```bash
singularity exec 3d_very_deep_vae.sif train_vae_model.py
```

Any flags or command line arguments can be declared after the script name.

For training, you will need to supply the `--nv` flag to singularity so that
the host GPU may be used.

## Generating Synthetic Data

The code in this example is [intended to be trained on neuroimaging
data](https://github.com/high-dimensional/3d_very_deep_vae#input-data). As this
is personal, sensitive, medical data it is not always practical to work with.
The project therefore includes a script to generate a synthetic dataset of
volumetric images of ellipsoids with noise.

To generate a synthetic dataset use the `generate_synthetic_data.py` script

```bash
singularity exec 3d_very_deep_vae.sif generate_synthetic_data.py --voxels_per_axis <resolution> --number_of_files <number_of_files> --output_directory <data_directory>
```

`<resolution>` is an integer that that specifies the resolution of input images.
Each input image has `<resolution>` voxels in each spatial dimension.
`<number_of_files>` images will be created. Images are stored in
`<data_directory>`. For example, to create 10,000 volumetric images with a
resolution of 32x32x32 run

```bash
singularity exec 3d_very_deep_vae.sif generate_synthetic_data.py --voxels_per_axis 32 --number_of_files 10000 --output_directory ./data
```

The dataset will be placed in the `data` directory.

## Training

A configuration file is required in order to train a model. The [examples
included in the
repository](https://github.com/high-dimensional/3d_very_deep_vae/tree/main/example_configurations)
can be written to the current directory using the `get_configs` script

```bash
singularity exec 3d_very_deep_vae.sif get_configs
```

This will write three files `VeryDeepVAE_32x32x32.json`,
`VeryDeepVAE_64x64x64.json` and  `VeryDeepVAE_128x128x128.json`. Each file
targets a different resolution for generated images.

All three example should fit within 32GiB of device memory. For GPUs with less
memory, the `batch_size` variable in the configuration files can be decreased.

Use The `train_vae_model.py` script to train a model

```bash
singularity exec --nv 3d_very_deep_vae.sif train_vae_model.py --json_config_file <config_file>  --nifti_dir <data_directory> --output_dir <output_directory>
```

For example, with the example configuration and synthetic data set above

```bash
singularity exec --nv 3d_very_deep_vae.sif train_vae_model.py --json_config_file VeryDeepVAE_32x32x32.json --nifti_dir ./data --output_dir ./output
```
