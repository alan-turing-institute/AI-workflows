#!/bin/bash

##########
# Slurm parameters
##########

# Set QoS
#SBATCH --qos=%qos

# Set partition
#SBATCH --partition=%partition

# Set the number of nodes
#SBATCH --nodes=1

# Set max wallclock time
#SBATCH --time=01:00:00

# Set name of job
#SBATCH --job-name=sciml_MNIST_tf_keras

# Set number of GPUs
#SBATCH --gres=gpu:1

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
scratch="$scratch_host/$job_id"
# Files and directories to copy to scratch before the job
inputs="datasets/MNIST"
# File and directories to copy from scratch after the job
outputs="output_$job_id"
# Singularity container
container="sciml-bench_cu11.sif"
# Singularity 'exec' command
container_command="sciml-bench run MNIST_tf_keras --output_dir=./output_$job_id --dataset_dir=/scratch_mount/MNIST"
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

# Copy inputs to scratch
mkdir -p "$scratch"
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
