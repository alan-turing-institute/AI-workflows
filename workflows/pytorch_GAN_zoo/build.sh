#!/bin/bash

_UID=$(id -u)
NAME="pytorch_GAN_zoo"
DEF_FILE="$NAME.def"
SIF_FILE="$NAME.sif"

TORCH_VERSION="1.9.1"
CUDA_VERSION="11.1"
TORCH_NAME="pytorch_${TORCH_VERSION}_cu_$CUDA_VERSION"
TORCH_DEF_FILE="$TORCH_NAME.def"
TORCH_SIF_FILE="$TORCH_NAME.sif"

pushd ../../base_containers/pytorch/ || exit
if ! [ -f $TORCH_SIF_FILE ]; then
    if ! [ -f $TORCH_DEF_FILE ]; then
        ./template.py $TORCH_VERSION $CUDA_VERSION
    fi

    if [ "$_UID" = 0 ]; then
        singularity build $TORCH_SIF_FILE $TORCH_DEF_FILE
    else
        singularity build --fakeroot $TORCH_SIF_FILE $TORCH_DEF_FILE
    fi
fi

popd || exit
if [ "$_UID" = 0 ]; then
    singularity build $SIF_FILE $DEF_FILE
else
    singularity build --fakeroot $SIF_FILE $DEF_FILE
fi
