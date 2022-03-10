#!/bin/bash

_UID=$(id -u)
DEF_FILE="pytorch_GAN_zoo.def"
SIF_FILE="pytorch_GAN_zoo.sif"

TORCH_DEF_FILE="pytorch_cu_11.1.def"
TORCH_SIF_FILE="pytorch_cu_11.1.sif"

pushd ../../base_containers/pytorch/ || exit
if ! [ -f $TORCH_SIF_FILE ]; then
    if ! [ -f $TORCH_DEF_FILE ]; then
        ./template.py 11.1
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
