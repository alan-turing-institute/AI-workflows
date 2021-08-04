#!/usr/bin/env sh
ROUTE=https://www.cs.toronto.edu/~kriz/
ARCHIVE=cifar-10-python.tar.gz
wget "$ROUTE$ARCHIVE" &&
tar -xf $ARCHIVE &&
rm -r $ARCHIVE
