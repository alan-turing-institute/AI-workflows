#!/bin/bash

CONTAINER="<CONTAINER_NAME>"
SCRATCH_PATH="/tmp/"

case $1 in
"MNIST_torch" )
    DATASET_NAME="MNIST";;
"MNIST_tf_keras" )
    DATASET_NAME="MNIST";;
"em_denoise" )
    DATASET_NAME="em_graphene_sim";;
"dms_structure" )
    DATASET_NAME="dms_sim";;
"slstr_cloud" )
    DATASET_NAME="slstr_cloud_ds1";;
* )
    echo "Please specify one of {'MNIST_torch', 'MNIST_tf_keras', 'em_denoise', 'dms_structure', 'slstr_cloud'}"
    exit 1;;
esac

mkdir -p "${STORAGE_PATH}${SLURM_JOB_NAME}"
mkdir -p "${SCRATCH_PATH}${SLURM_JOB_NAME}"

if [[ ! -d ${STORAGE_PATH}"datasets/${DATASET_NAME}" ]]
then
	singularity run --nv ${STORAGE_PATH}${CONTAINER} download ${DATASET_NAME} --dataset_root_dir=${STORAGE_PATH}"datasets/"
fi
