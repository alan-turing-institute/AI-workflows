#!/bin/bash

# Set the QOS
##SBATCH --qos=turing

# set the number of nodes
#SBATCH --nodes=1

# set max wallclock time
#SBATCH --time=1-23:59:59

# set name of job
#SBATCH --job-name=sciml-runs

# set number of GPUs
#SBATCH --gres=gpu:1

# mail alert at start, end and abortion of execution
#SBATCH --mail-type=ALL

# send mail to this address
#SBATCH --mail-user=<email-here>


module purge;
module load baskerville

CONTAINER="<CONTAINER_NAME>"
SCRATCH_PATH="/tmp/"

BENCHMARK_ID=$(( ${SLURM_ARRAY_TASK_ID} % 5 ))

if [[ ${BENCHMARK_NAME} == "MNIST_torch" ]]
then
  DATASET_NAME="MNIST"
elif [[ ${BENCHMARK_NAME} == "MNIST_tf_keras" ]]
then
  DATASET_NAME="MNIST"
elif [[ ${BENCHMARK_NAME} == "em_denoise" ]]
then
  DATASET_NAME="em_graphene_sim"
elif [[ ${BENCHMARK_NAME} == "dms_structure" ]]
then
  DATASET_NAME="dms_sim"
elif [[ ${BENCHMARK_NAME} == "slstr_cloud" ]]
then
  DATASET_NAME="slstr_cloud_ds1"
fi
# ------

mkdir -p "${STORAGE_PATH}${SLURM_JOB_NAME}"
mkdir -p "${SCRATCH_PATH}${SLURM_JOB_NAME}"

if [[ ! -d ${STORAGE_PATH}"datasets/${DATASET_NAME}" ]]
then
	singularity run --nv ${STORAGE_PATH}${CONTAINER} download ${DATASET_NAME} --dataset_root_dir=${STORAGE_PATH}"datasets/"
fi

if [[ ${BENCHMARK_NAME} == "slstr_cloud" ]]
then
	echo "Skipping copy as dataset too large!"
elif [[ ! -d ${SCRATCH_PATH}"datasets/${DATASET_NAME}" ]]
then
  if [[ ! -d ${SCRATCH_PATH}"datasets/" ]]
  then
    mkdir -p ${SCRATCH_PATH}"datasets/"
  fi
  cp -R --strip-trailing-slashes ${STORAGE_PATH}"datasets/${DATASET_NAME}/" ${SCRATCH_PATH}"datasets"
fi

start_time=$(date -Is --utc)
echo "started: $start_time"
nvidia-smi dmon -o TD -s puct -d 1 > ${SCRATCH_PATH}dmon.txt & gpu_watch_pid=$!

if [[ ${BENCHMARK_NAME} == "slstr_cloud" ]]
then
  singularity run --nv --bind ${SCRATCH_PATH}:${SCRATCH_PATH} ${STORAGE_PATH}${CONTAINER} run ${BENCHMARK_NAME} --output_dir="${SCRATCH_PATH}${SLURM_JOB_NAME}/${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}_${BENCHMARK_NAME}" --dataset_dir=${STORAGE_PATH}"datasets/${DATASET_NAME}"
else
  singularity run --nv --bind ${SCRATCH_PATH}:${SCRATCH_PATH} ${STORAGE_PATH}${CONTAINER} run ${BENCHMARK_NAME} --output_dir="${SCRATCH_PATH}${SLURM_JOB_NAME}/${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}_${BENCHMARK_NAME}" --dataset_dir=${SCRATCH_PATH}"datasets/${DATASET_NAME}"
fi

kill $gpu_watch_pid
end_time=$(date -Is --utc)
echo "finished: $end_time"

mv ${SCRATCH_PATH}${SLURM_JOB_NAME}/${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}_${BENCHMARK_NAME} ${STORAGE_PATH}${SLURM_JOB_NAME}
mv ${SCRATCH_PATH}dmon.txt "${STORAGE_PATH}${SLURM_JOB_NAME}/${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}_${BENCHMARK_NAME}_dmon.txt"
