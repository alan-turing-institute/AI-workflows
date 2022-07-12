#!/bin/bash

CONTAINER=$1
BENCHMARK_NAME=$2

case ${BENCHMARK_NAME} in
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


if [[ ! -d "datasets/${DATASET_NAME}" ]]
then
	singularity run --nv ${CONTAINER} download ${DATASET_NAME} --dataset_root_dir="datasets/"
fi
