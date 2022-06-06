#!/bin/bash

##########
# Slurm parameters
##########

# Set QoS
#SBATCH --qos=%qos

# Sert partition
#SBATCH --partition=%partition

# Set the number of nodes
#SBATCH --nodes=%nodes

# Set max wallclock time
#SBATCH --time=%wall_time

# Set name of job
#SBATCH --job-name=%job_name

# Set number of GPUs
#SBATCH --gres=gpu:%gpus

##########
# Modules
##########

module purge
module load %modules

##########
# Job parameters
##########

# Unique Job ID, either the Slurm job ID or Slurm array ID and task ID when an
# array job
if [ "$SLURM_ARRAY_JOB_ID" ]; then
    job_id="${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}"
else
    job_id="$SLURM_JOB_ID"
fi

# Path to scratch directory on host
scratch_host="%scratch_host"
# Files and directories to copy to scratch before the job
inputs="%inputs"
# File and directories to copy from scratch after the job
outputs="%outputs"
# Singularity container
container="%container"
# Singularity 'exec' command
container_command="%container_command"
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
scratch="$scratch_host/$job_id"
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
nvidia-smi dmon -o TD -s puct -d 1 > "dmon_$job_id".txt &
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
