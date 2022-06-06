#!/bin/bash

##########
# Slurm parameters
##########

# Set QoS
#SBATCH --qos=...

# Set partition
#SBATCH --partition=...

# Set the number of nodes
#SBATCH --nodes=1

# Set max wallclock time
#SBATCH --time=6-00:00:00

# Set name of job
#SBATCH --job-name=pytorch_gan_zoo_cifar10

# Set number of GPUs
#SBATCH --gres=gpu:1

##########
# Modules
##########

module purge
module load ...

##########
# Job parameters
##########

# Path to scratch directory on host
scratch_host="..."
# Files and directories to copy to scratch before the job
inputs="cifar10 config_cifar10.json"
# File and directories to copy from scratch after the job
outputs="output_networks/cifar10_${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}"
# Singularity container
container="pytorch_GAN_zoo.sif"
# Singularity 'exec' command
container_command="train.py PGAN -c config_cifar10.json --restart --no_vis -n cifar10_${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}"
# Command to execute
run_command="singularity exec
  --nv
  --bind $scratch:/scratch_mount
  --pwd /scratch_mount
  $container
  $container_command"

##########
# Set up scratch
##########

# Scratch directory
scratch="$scratch_host/$SLURM_JOB_ID"
mkdir -p "$scratch"

# Copy inputs to scratch
for item in $inputs; do
    echo "Copying $item to scratch"
    cp -r "$item" "$scratch"
done

##########
# Monitor and run job
##########

# Monitor GPU usage
nvidia-smi dmon -o TD -s puct -d 1 > "dmon_${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}".txt &
gpu_watch_pid=$!

# run the application
start_time=$(date -Is --utc)
$run_command
end_time=$(date -Is --utc)

# Stop GPU monitoring
kill $gpu_watch_pid

# Print summary
echo "executed: $run_command"
echo "started: $start_time"
echo "finished: $end_time"

##########
# Copy outputs
##########

# Copy output from scratch
for item in $outputs; do
    echo "Copying $item from scratch"
    cp -r "$scratch/$item" ./
done

# Clean up scratch directory
rm -rf "$scratch"
