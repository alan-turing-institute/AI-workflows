# Sciml-bench

This workflow containerises the
[sciml-bench](https://github.com/stfc-sciml/sciml-bench) suite of benchmarks,
with a configuration that is compatible with CUDA11.  SciMLBench is a
benchmarking suite developed at STFC, designed specifically for the AI for
Science domain.

## Building

To build the singularity containers use the build script in this directory.

```bash
./build.sh
```

This script will try to use singularity's [fakeroot
support](https://sylabs.io/guides/main/user-guide/fakeroot.html) if you run as a
non-root user. If this is not supported on your system you can run the script as
root.

When the script is finished you will find the containers (`ompi4.sif` and
`sciml-bench_cu11.sif`) in your current working directory. The `ompi4.sif`
container is just used as a base image to build the `sciml-bench_cu11.sif`
container.  Only the `sciml-bench_cu11.sif` container is required to run the
benchmarks.

## Fetching Datasets

Once the singularity container has been built, the datasets can be downloaded
using the sciml-bench `download` command:

```bash
singularity run --nv sciml-bench_cu11.sif download <DATASET> --dataset_root_dir=datasets/
```

| `<DATASET>`       | description                                      | required for benchmarks         |
|-------------------|--------------------------------------------------|---------------------------------|
| `MNIST`           | The MNIST database of handwritten digits         | `MNIST_torch`, `MNIST_tf_keras` |
| `dms_sim`         | Simulated diffuse multiple scattering patterns   | `dms_structure`                 |
| `em_graphene_sim` | Simulated electron microscopy images of graphene | `em_denoise`                    |
| `slstr_cloud_ds1` | Sentinel-3 SLSTR satellite image data            | `slstr_cloud`                   |

## Running Benchmarks

The benchmarks can be run from the singularity container according to the
usage instructions found in the [sciml-bench](https://github.com/stfc-sciml/sciml-bench/blob/2c5035d4ea57ee7d2cde8ef805b756fc2d061f92/doc/usage.md#32-running-benchmarks)
repository.

```bash
singularity run --nv sciml-bench_cu11.sif run <BENCHMARK> --dataset_dir=datasets/<DATASET> --output_dir=<OUTPUT_DIRECTORY>
```

Benchmark and dataset names are in the table in the [previous section](#fetching-datasets).
`OUTPUT_DIRECTORY` is the desired location to save outputs.

### MNIST Torch

```bash
singularity run --nv sciml-bench_cu11.sif run MNIST_torch --dataset_dir=datasets/MNIST --output_dir=output/MNIST_torch
```

### MNIST Tensorflow Keras

```bash
singularity run --nv sciml-bench_cu11.sif run MNIST_tf_keras --dataset_dir=datasets/MNIST --output_dir=output/MNIST_tf_keras
```

### DMS Structure

```bash
singularity run --nv sciml-bench_cu11.sif run dms_sim --dataset_dir=datasets/dms_structure --output_dir=output/dms_sim
```

### EM Denoise

```bash
singularity run --nv sciml-bench_cu11.sif run em_graphene_sim --dataset_dir=datasets/em_denoise --output_dir=output/em_graphene_sim
```

### SLSTR Cloud

```bash
singularity run --nv sciml-bench_cu11.sif run slstr_cloud_ds1 --dataset_dir=datasets/slstr_cloud --output_dir=output/slstr_cloud_ds1
```

## Running Benchmarks on HPC

The [`batch_scripts`](./batch_scripts) directory contains template Slurm batch
scripts for running each of the benchmarks.

These scripts expect the datasets to be found in a `dataset/` subdirectory of
the current working directory as they would be following the instructions above.

They demonstrate the advice for running on HPC explained [here](../../hpc.md).
This includes using scratch space, parametrising output file names and
supporting job arrays.

To submit a job, complete a template filling in placeholders (beginning with
`%`) with values appropriate for the platform you are using. Use `sbatch` to
submit a job. For example

```bash
sbatch sciml_dms_structure.sh
```

Or as a job array

```bash
sbatch --array=1-5%2 sciml_dms_structure.sh
```
