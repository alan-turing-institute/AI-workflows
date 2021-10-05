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

Here is an example which could be incorporated into a SLURM script. This will
display

- Time and date
- Power usage in Watts
- GPU and memory temperature in C
- Streaming multiprocessor, memory, encoder and decoder utilisation as a % of
  maximum
- Processor and memory clock speeds in MHz
- PCIe throughput input (Rx) and output (Tx) in MB/s

Every 300 seconds this information will be saved to a file named using the
SLURM array job and task IDs as discussed in [the SLURM
section](#parametrising-job-arrays)

This job is sent to the background and stopped after the `$command` has run.

```bash
...

nvidia-smi dmon -o TD -s puct -d 300 > "dmon-${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}".txt &
gpu_watch_pid=$!

$command

kill $gpu_watch_pid

...
```

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

### Benchmarking

### Using scratch space

### Repeated runs (job arrays)

If you are assessing a systems performance you will likely want to repeat the
same calculation a number of times until you are satisfied with you estimate of
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

### Parametrising job arrays

One particularly powerful way to use job arrays is through parametrising the
individual tasks. For example, this could be used to sweep over a set of input
parameters or data sets. As with using job array for repeating jobs, this will
likely be more convenient than implementing your own solution.

Within your batch script you will have access to the following environment
variables

| environment variable      | value                    |
|---------------------------|--------------------------|
| `SLURM_ARRAY_JOB_ID`      | job id of the first task |
| `SLURM_ARRAY_TASK_ID`     | current task index       |
| `SLURM_ARRAY_TASK_COUNT ` | total number of tasks    |
| `SLURM_ARRAY_TASK_MAX`    | the highest index value  |
| `SLURM_ARRAY_TASK_MIN`    | the lowest index value   |

For example, if you submitted a job array with the command

```bash
$ sbatch --array=0-12:4 script.sh
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

with the same submission command would execute the following commands (one in
each job)

- `my_program -n 0 -o output_42_0`
- `my_program -n 4 -o output_42_4`
- `my_program -n 8 -o output_42_8`
- `my_program -n 12 -o output_42_12`

### Template
