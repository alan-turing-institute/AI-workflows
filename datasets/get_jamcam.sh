#!/usr/bin/env sh
ROUTE=https://zenodo.org/record/6472731/files/
ARCHIVE=task_jamcams_groundtruth.zip
wget "$ROUTE$ARCHIVE?download=1" -O $ARCHIVE &&
mkdir jamcams_data &&
unzip $ARCHIVE -d jamcams_data &&
rm -r $ARCHIVE