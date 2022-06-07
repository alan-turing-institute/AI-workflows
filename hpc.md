# HPC

## Nvidia SMI

When using as system with an Nvidia GPU, the `nvidia-smi` utility will likely be
installed. This program can be used to monitor and manage for Nvidia devices.
By default (*i.e.* with no arguments) the command will display a summary of
devices, driver and CUDA version and GPU processes.

By using the `dmon` command `nvidia-smi` can also be used to periodically print
selected metrics, include GPU utilisation, GPU temperature and GPU memory
utilisation, at regular intervals.

```bash
$ nvidia-smi dmon
# gpu   pwr gtemp mtemp    sm   mem   enc   dec  mclk  pclk
# Idx     W     C     C     %     %     %     %   MHz   MHz
    0    32    49     -     1     1     0     0  4006   974
    0    32    49     -     2     2     0     0  4006   974
```

The columns displayed, format and interval can all be configured. The manpage of
`nvidia-smi` gives full details (`man nvidia-smi`).

Here is an example which could be incorporated into a Slurm script. This will
display

- Time and date
- Power usage in Watts
- GPU and memory temperature in C
- Streaming multiprocessor, memory, encoder and decoder utilisation as a % of
  maximum
- Processor and memory clock speeds in MHz
- PCIe throughput input (Rx) and output (Tx) in MB/s

This job is sent to the background and stopped after the `$command` has run.

```bash
nvidia-smi dmon -o TD -s puct -d 1 > dmon.txt &
gpu_watch_pid=$!

$command

kill $gpu_watch_pid
```

## Modules

HPC systems will almost certainly have a module system which helps manage and
isolate the many (potentially conflicting) packages users want. Although
singularity allows us to package most workflow requirements inside a container
image, using GPUs requires a compatible set of driver and library packages on the
host. You may, therefore, need to load the appropriate modules to run the
workflows.

There are two common module systems,
[Lmod](https://lmod.readthedocs.io/en/latest/index.html) and [Environment
Modules](https://modules.readthedocs.io/en/latest/). For a user the differences
between the two are not important as the commands are the same.

To list the available modules

```bash
module av
```

And to load a particular module

```bash
module load ...
```

When submitting batch jobs any `module load` commands should be placed in your
batch script.

## Slurm

When running these workflows on HPC you will most likely use the
[Slurm](https://www.schedmd.com/) scheduler to submit, monitor and manage your
jobs.

The Slurm website provide a users
[tutorial](https://slurm.schedmd.com/tutorials.html) and
[documentation](https://slurm.schedmd.com/documentation.html) which have
comprehensive detail of Slurm and its commands.

In particular interest to users are

- [Slurm command man pages](https://slurm.schedmd.com/man_index.html)
- [Slurm command summary cheat
  sheet](https://slurm.schedmd.com/pdfs/summary.pdf)
- [Array support overview](https://slurm.schedmd.com/job_array.html)

This section does not aim to be a comprehensive guide to Slurm, or even a brief
introduction. Instead, it is intended to provide suggestions and a template for
running this projects workflows on a cluster with Slurm.

### Requesting GPUs

To request GPUs for a job in Slurm you may use the [Generic Resource
(GRES)](https://slurm.schedmd.com/gres.html#Running_Jobs) plugin. The precise
details of this will depend on the cluster you are using (for example
requesting a particular model of GPU), however in most cases you will be able
to request `n` GPUs with the flag `--gres=gpu:n`. For example

```bash
$ srun --gres=gpu:1 my_program
Submitted batch job 42

$ sbatch --gres=gpu:4 script.sh
Submitted batch job 43
```

Or in a batch script

```bash
#SBATCH --gres=gpu:1
```

### Benchmarking

A rudimentary way to monitor performance is to measure how long a given task
takes to complete. One way to do achieve this, if the software you are running
provides no other way, is to run the `date` command before and after your
program.

```bash
date --iso-8601=seconds --utc
# Commands to time
date --iso-8601=seconds --utc
```

The flag and parameter `--iso-8601=seconds` ensures the output is in the ISO
8601 format with precision up to and including seconds. The `--utc` flag means
that the time will be printed in Coordinated Universal Time.

The programs start and end times will then be recorded in the STDOUT file.

### Repeated Runs (Job Arrays)

If you are assessing a systems performance you will likely want to repeat the
same calculation a number of times until you are satisfied with your estimate of
mean performance. It would be possible to simply repeatedly submit the same job
and many people are tempted to engineer their own scripts to do so. However,
Slurm provides a way to submit groups of jobs that you will most likely find
more convenient.

When submitting a job with `sbatch` you can specify the size of your job array
with the `--array=` flag using a range of numbers *e.g* `0-9` or a comma
separated list *e.g.* `1,2,3`. You can use `:` with a range to specify a stride,
for example `1-5:2` is equivalent to `1,3,5`. You may also specify the maximum
number of jobs from an array that may run simultaneously using `%` *e.g.*
`0-31%4`.

Here are some examples

```bash
# Submit 10 jobs with indices 1,2,3,..,10
sbatch --array=1-10 script.sh

# Submit 5 jobs with indices 1, 4, 8, 12, 16 and at most two of these running
# simultaneously
sbatch --array=1-16:4%2 script.sh
```

### Parametrising Job Arrays

One particularly powerful way to use job arrays is through parametrising the
individual tasks. For example, this could be used to sweep over a set of input
parameters or data sets. As with using job array for repeating jobs, this will
likely be more convenient than implementing your own solution.

Within your batch script you will have access to the following environment
variables

| environment variable     | value                    |
|--------------------------|--------------------------|
| `SLURM_ARRAY_JOB_ID`     | job id of the first task |
| `SLURM_ARRAY_TASK_ID`    | current task index       |
| `SLURM_ARRAY_TASK_COUNT` | total number of tasks    |
| `SLURM_ARRAY_TASK_MAX`   | the highest index value  |
| `SLURM_ARRAY_TASK_MIN`   | the lowest index value   |

For example, if you submitted a job array with the command

```bash
$ sbatch --array=0-12%4 script.sh
Submitted batch job 42
```

then the job id of the first task is `42` and the four jobs will have
`SLURM_ARRAY_JOB_ID`, `SLURM_ARRAY_TASK_ID` pairs of

- 42, 0
- 42, 4
- 42, 8
- 42, 12

The environment variables can be used in your commands. For example

```bash
my_program -n $SLURM_ARRAY_TASK_ID -o output_${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}
```

with the same `sbatch` command as before, the following commands would be
executed in your jobs (one in each job)

- `my_program -n 0 -o output_42_0`
- `my_program -n 4 -o output_42_4`
- `my_program -n 8 -o output_42_8`
- `my_program -n 12 -o output_42_12`

### Using Scratch Space

Most HPC systems will offer some sort of fast, temporal and typically on-node,
storage such as NVMe SSDs. In calculations where reading or writing data is a
bottleneck, using this storage will be key to optimising performance.

The location of scratch space will differ between HPC systems so it is
unavoidable to have some platform specific data in batch scripts. However, with
a sensible template, taking advantage of Singularity's `--bind` and `--pwd`
flags these adjustments can be made less tedious and more robust.

The following snippet shows how this may be done.

```bash
scratch_host="%scratch_host"
scratch="$scratch_host/$SLURM_JOB_ID"
inputs="%inputs"
outputs="%outputs"

# Copy inputs to scratch
mkdir -p "$scratch"
for item in $inputs; do
    echo "Copying $item to scratch"
    cp -r "$item" "$scratch"
done

# Run the application
singularity exec \
--nv \
--bind $scratch:/scratch_mount \
--pwd /scratch_mount
%container %container_command

# Copy output from scratch
for item in $outputs; do
    echo "Copying $item from scratch"
    cp -r "$scratch/$item" ./
done

# Clean up
rm -rf "$scratch"
```

`%scratch_host` is the path to scratch directory on host, for example
`/scratch`. `%inputs` is a *space separated* list of files and directories
needed for the job, for example`input_file.txt data_directory`.  `%outputs` is
also a space separated list of files and directories. These are files and
directories produced by the job that should be kept.

The input files and directories declared are copied to `$scratch`. This
directory is then mounted in the container at `/scratch_mount` with the `--bind
$scratch:/scratch_mount` argument. The `--pwd /scratch_mount` flag ensures that
the command (`%container_command`) is executed in the `/scratch_mount`
directory inside the container, _i.e._ where the input data is. This way the
input data is both stored on the fast scratch storage and visible to the
container process.

Note, simply changing directory to `$scratch` before running singularity is
unlikely to work. When Singularity is run inside of a users home directory the
current working directory is mounted and used as the initial directory for the
container process. Scratch space will almost certainly be outside of a users
home directory, in which case the current working directory is not mounted and
the initial directory inside the container is `/`.

This example uses array job id and array task id to reduce the possibility of a
name clash when using the scratch space. Ideally each job will be given a
scratch directory in a unique namespace so there is no possibility of file or
directory names clashing between different jobs, but this will not be the case
on all HPC systems.

### Template

Collecting the above tips, here is a template batch script that can be adapted
to run these (or other) calculations on clusters with the Slurm scheduler.

[`batch_template.sh`](workflows/batch_template.sh) is a template batch script
putting together all of the tips above. This template can be adapted to run the
AI workflows. More complete examples are included alongside each workflow.
