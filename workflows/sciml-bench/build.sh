#!/bin/bash

_UID=$(id -u)
OMPI4_NAME="ompi4_cu11"
SCIML_NAME="sciml-bench_cu11"

OMPI4_DEF_FILE="$OMPI4_NAME.def"
OMPI4_SIF_FILE="$OMPI4_NAME.sif"
SCIML_DEF_FILE="$SCIML_NAME.def"
SCIML_SIF_FILE="$SCIML_NAME.sif"

if [ "$_UID" = 0 ]; then
    singularity build $OMPI4_SIF_FILE "def_files/"$OMPI4_DEF_FILE
    singularity build $SCIML_SIF_FILE "def_files/"$SCIML_DEF_FILE
else
    singularity build --fakeroot $OMPI4_SIF_FILE "def_files/"$OMPI4_DEF_FILE
    singularity build --fakeroot $SCIML_SIF_FILE "def_files/"$SCIML_DEF_FILE
fi
