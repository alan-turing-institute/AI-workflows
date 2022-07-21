#!/bin/bash

data_dir='./workspace/data'

mkdir -p $data_dir

pushd $data_dir || exit

# download ground truth data
wget https://zenodo.org/record/6472731/files/task_jamcams_groundtruth.zip -O task_jamcams_groundtruth.zip

sha256sum "task_jamcams_groundtruth.zip" | cut -d ' ' -f 1 | grep -xq '^0d8aa6d26dac35c85ad0d910242dedbb970e54f18c2d9be45469697eac168673$'

if test $? -eq 0; then
    echo "zip OK"
else
    echo "zip corrupt, re-download!"
    rm -f "task_jamcams_groundtruth.zip"
    exit 1
fi

wget --content-disposition https://api.ngc.nvidia.com/v2/models/nvidia/iva/tlt_resnet18_ssd/versions/1/zip -O tlt_resnet18_ssd_1.zip

mkdir -p train/images \
         train/labels_raw \
         test/images \
         test/labels_raw

unzip task_jamcams_groundtruth.zip -d jamcams_data

pushd jamcams_data/data/obj_train_data/ || exit

find . -wholename '*.jpg' | head -n 1000 | xargs -I {} mv {} ../../train/images
find . -wholename '*.txt' | head -n 1000 | xargs -I {} mv {} ../../train/labels_raw
find . -wholename '*.jpg' | head -n 141 | xargs -I {} mv {} ../../test/images
find . -wholename '*.txt' | head -n 141 | xargs -I {} mv {} ../../test/labels_raw

popd || exit
popd || exit
