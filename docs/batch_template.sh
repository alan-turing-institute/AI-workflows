#!/bin/bash

##########
# Slurm parameters
##########

# set QoS
#SBATCH --qos=...

# set the number of nodes
#SBATCH --nodes=...

# set max wallclock time
#SBATCH --time=...

# set name of job
#SBATCH --job-name=...

# set number of GPUs
#SBATCH --gres=gpu:...

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
inputs="..."
# File and directories to copy from scratch after the job
outputs="..."
# Singularity container
container="... .sif"
# Singularity 'exec' command
container_command="..."
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
nvidia-smi dmon -o TD -s puct -d 1 > "dmon-${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}".txt &
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
