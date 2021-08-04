#!/usr/bin/env sh
ROUTE=https://www.robots.ox.ac.uk/~vgg/data/dtd/download/
ARCHIVE=dtd-r1.0.1.tar.gz
wget "$ROUTE$ARCHIVE" &&
tar -xf $ARCHIVE &&
rm -r $ARCHIVE
