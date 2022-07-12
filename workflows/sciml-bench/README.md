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

This script will try to use singularities [fakeroot
support](https://sylabs.io/guides/main/user-guide/fakeroot.html) if you run as a
non-root user. If this is not supported on your system you can run the script as
root.

When the script is finished you will find the containers (`ompi4.sif` and `sciml-bench_cu11.sif`)
in your current working directory. The `ompi4.sif` container is just used as a base image to build the `sciml-bench_cu11.sif` container. 
Only the `sciml-bench_cu11.sif` container is required to run the benchmarks.


## Running containers

The singularity containers can be run according to the 
usage instructions found in the [sciml-bench](https://github.com/stfc-sciml/sciml-bench/blob/master/doc/usage.md) 
repository. Alternatively, batch submission scripts have been provided that fit the [recommended template](https://github.com/alan-turing-institute/AI-workflows/blob/main/workflows/batch_template.sh).
Submit these scripts using slurm as follows:
```
sbatch <SCRIPT NAME>.sh
```
These scripts expect the datasets to be found in a `dataset/` subdirectory of the current working directory 
(where the script itself is found).


### Fetching Datasets

Once the singularity container has been built, the datasets can be downloaded using the `get_data.sh` script:
```
./get_data.sh <CONTAINER NAME> <BENCHMARK NAME>
```
where the container name is the `sciml-bench_cu11.sif` file and the benchmark name is one of 
{'MNIST_torch', 'MNIST_tf_keras', 'em_denoise', 'dms_structure', 'slstr_cloud'}
