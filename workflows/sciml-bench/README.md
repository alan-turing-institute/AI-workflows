# Sciml-bench

https://github.com/stfc-sciml/sciml-bench

## Usage

[Singularity](https://sylabs.io/singularity/) is used to run these benchmarks.
[See the docs](https://sylabs.io/guides/latest/user-guide/quick_start.html#quick-installation-steps) for steps to install Singularity on Linux.

This repository contains various Singularity `def` files that define different versions of the containers used to run the [sciml-bench](https://github.com/stfc-sciml/sciml-bench) benchmarks.
Unless otherwise stated, the code for the benchmarks remains the same in each case.

### Building containers with Singularity

```
sudo singularity build <container_name>.sif def_files/<container_name>.def
```

### Running containers

On Baskerville, you can run the benchmarks (5 times) using the following command
```
sbatch -J "<OUTPUT_DIRECTORY_NAME>" --export=STORAGE_PATH="<PATH/TO/YOUR/DIRECTORY>",BENCHMARK_NAME="<BENCHMARK_NAME>"  --array=1-5%1 --qos=turing  baskerville_runs.sh
```

where
- OUTPUT_DIRECTORY_NAME is the name of the directory that will be created to store all sciml-bench outputs (except for slurm outputs)
- STORAGE_PATH is the path to your project disk space
- BENCHMARK_NAME is one of {'MNIST_torch', 'MNIST_tf_keras', 'dms_structure', 'em_denoise', 'slstr_cloud'}

### Baskerville submission script

The script provided `baskerville_runs.sh` initially checks if the required dataset can be found at the <STORAGE_PATH>. If not, it is downloaded.

If the dataset is found, it is copied into the temporary scratch space (unless, as is the case for the slstr_cloud benchmark, the dataset is too large).

The nvidia-smi daemon is then started, and the benchmark is run. After the benchmark completes, the daemon is stopped, and all generated outputs are copied from the temporary scratch space to persistent storage.
