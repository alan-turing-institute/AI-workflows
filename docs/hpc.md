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

Every 300 seconds this information will be saved to a file named using the SLURM
array job and task IDs as discussed in [the SLURM section](#slurm)

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
