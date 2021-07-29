#!/bin/sh

_UID=$(id -u)
DEF_FILE="pytorch_GAN_zoo.def"
SIF_FILE="pytorch_GAN_zoo.sif"

if [ "$_UID" = 0 ]; then
    singularity build $SIF_FILE $DEF_FILE
else
    singularity build --fakeroot $SIF_FILE $DEF_FILE
fi
