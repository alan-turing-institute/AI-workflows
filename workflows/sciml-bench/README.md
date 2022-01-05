# Sciml-bench

https://github.com/stfc-sciml/sciml-bench

## Usage

[Singularity](https://sylabs.io/singularity/) is used to run these benchmarks. 
[See the docs](https://sylabs.io/guides/latest/user-guide/quick_start.html#quick-installation-steps) for steps to install Singularity on Linux.

This repository contains various Singularity `def` files that define different versions of the containers used to run the [sciml-bench](https://github.com/stfc-sciml/sciml-bench) benchmarks. 
Unless otherwise stated, the code for the benchmarks remains the same in each case. 

The differences between the containers produced by each of the def files are outlined below. 
In all cases, the def files found in the sciml-bench repository were used as a starting point, with only minor changes made.

| def file name | container description |
|-|-|
|               |                       |
|               |                       |

### Building containers with Singularity

```
sudo singularity build <container_name>.sif def_files/<container_name>.def
```

### Running containers

```
```
