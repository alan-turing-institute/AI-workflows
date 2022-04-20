#!/bin/bash

_UID=$(id -u)
NAME="nvidia-tao"
DEF_FILE="$NAME.def"
SIF_FILE="$NAME.sif"

TAO_VERSION="3.21.11"
TAO_NAME="nvidia-tao_$TAO_VERSION"
TAO_DEF_FILE="$TAO_NAME.def"
TAO_SIF_FILE="$TAO_NAME.sif"

pushd ../../base_containers/nvidia-tao/ || exit
if ! [ -f $TAO_SIF_FILE ]; then
    if ! [ -f $TAO_DEF_FILE ]; then
        ./template.py $TAO_VERSION
    fi

    if [ "$_UID" = 0 ]; then
        singularity build $TAO_SIF_FILE $TAO_DEF_FILE
    else
        singularity build --fakeroot $TAO_SIF_FILE $TAO_DEF_FILE
    fi
fi

popd || exit
if [ "$_UID" = 0 ]; then
    singularity build $SIF_FILE $DEF_FILE
else
    singularity build --fakeroot $SIF_FILE $DEF_FILE
fi