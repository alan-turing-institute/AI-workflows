#!/bin/sh

_UID=$(id -u)
DEF_FILE="time_domain_music_source_separation.def"
SIF_FILE="time_domain_music_source_separation.sif"

if [ "$_UID" = 0 ]; then
    singularity build $SIF_FILE $DEF_FILE
else
    singularity build --fakeroot $SIF_FILE $DEF_FILE
fi
