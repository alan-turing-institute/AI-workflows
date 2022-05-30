#! /usr/bin/env bash

case $1 in
"cifar10" )
    ROUTE=https://www.cs.toronto.edu/~kriz/
    ARCHIVE=cifar-10-python.tar.gz;;
"dtd" )
    ROUTE=https://www.robots.ox.ac.uk/~vgg/data/dtd/download/
    ARCHIVE=dtd-r1.0.1.tar.gz;;
* )
    echo "Please specify one of 'cifar10' or 'dtd'"
    exit 1;;
esac

wget "$ROUTE$ARCHIVE" &&
tar -xf $ARCHIVE &&
rm -r $ARCHIVE
