#!/bin/python

# download ground truth data
curl https://zenodo.org/record/6472731/files/task_jamcams_groundtruth.zip?download=1 -o workspace/data/task_jamcams_groundtruth.zip

# Check the dataset is present
if [ ! -f workspace/data/task_jamcams_groundtruth.zip ]; then echo 'Groundtruth zip file not found, please download.'; else echo 'Found Image zip file.'; fi

# may take a moment
sha256sum 'workspace/data/task_jamcams_groundtruth.zip' | cut -d ' ' -f 1 | grep -xq '^0d8aa6d26dac35c85ad0d910242dedbb970e54f18c2d9be45469697eac168673$' ; \
if test $? -eq 0; then echo "zip OK"; else echo "zip corrupt, re-download!" && rm -f 'workspace/data/task_jamcams_groundtruth.zip'; fi 

wget --content-disposition https://api.ngc.nvidia.com/v2/models/nvidia/iva/tlt_resnet18_ssd/versions/1/zip -O workspace/data/tlt_resnet18_ssd_1.zip