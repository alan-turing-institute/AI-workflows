# Sciml-bench

This workflow containerises the [sciml-bench](https://github.com/stfc-sciml/sciml-bench) suite
of benchmarks, with a configuration that is compatible with CUDA11.
SciMLBench is a benchmarking suite developed at STFC,
designed specifically for the AI for Science domain.

## Building

To build the singularity containers use the build script in this directory.

```bash
./build.sh
```

This script will try to use singularity's [fakeroot
support](https://sylabs.io/guides/main/user-guide/fakeroot.html) if you run as a
non-root user. If this is not supported on your system you can run the script as
root.

When the script is finished you will find the containers (`ompi4.sif` and `sciml-bench_cu11.sif`)
in your current working directory. The `ompi4.sif` container is just used as a base image to build the `sciml-bench_cu11.sif` container.
Only the `sciml-bench_cu11.sif` container is required to run the benchmarks.

## Fetching Datasets

Once the singularity container has been built, the datasets can be downloaded using the sciml-bench `download` command:

```
singularity run --nv sciml-bench_cu11.sif download <DATASET> --dataset_root_dir="datasets/"
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

```
singularity run --nv sciml-bench_cu11.sif run <BENCHMARK_NAME> --output_dir=<OUTPUT_DIRECTORY_NAME> --dataset_dir=/path/to/<DATASET_NAME>
```

where benchmark and dataset names are chosen from the options listed in the above section on Fetching Datasets, and OUTPUT_DIRECTORY_NAME is the desired location to save outputs.

## Running Benchmarks on HPC

Alternatively, [batch submission scripts](./batch_scripts/) have been provided that fit the [recommended template](https://github.com/alan-turing-institute/AI-workflows/blob/main/workflows/batch_template.sh).
Submit these scripts using slurm as follows:

```
sbatch /path/to/<SCRIPT NAME>.sh
```

These scripts expect the datasets to be found in a `dataset/` subdirectory of the current working directory
(where the script itself is found).
