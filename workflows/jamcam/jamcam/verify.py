

import os
import json

# more envs
os.environ["LOCAL_DATA_DIR"] = os.path.join(os.getenv("LOCAL_PROJECT_DIR", os.getcwd()), "data")
os.environ["LOCAL_EXPERIMENT_DIR"] = os.path.join(os.getenv("LOCAL_PROJECT_DIR", os.getcwd()), "yolo_v4")
DATA_DIR = os.environ.get('LOCAL_DATA_DIR')

# Mapping up the local directories to the TAO docker.
mounts_file = os.path.expanduser(".tao_mounts.json")

# Define the dictionary with the mapped drives
drive_map = {
    "Mounts": [
        # Mapping the data directory
        {
            "source": os.environ["LOCAL_PROJECT_DIR"],
            "destination": "/workspace/tao-experiments"
        },
        # Mapping the specs directory.
        {
            "source": os.environ["LOCAL_SPECS_DIR"],
            "destination": os.environ["SPECS_DIR"]
        },
    ]
#     ,
#     "DockerOptions": {
#         "runArgs": [
#             "--gpus", "all"
#         ]
#     }
}

# Writing the mounts file.
print('Writing TAO mounts file', mounts_file)
with open(mounts_file, "w") as mfile:
    json.dump(drive_map, mfile, indent=4)

# convert to tao format
from os import listdir
import glob
import pandas as pd
import numpy as np
names = np.array(['person','bicycle','car','motorbike','bus','truck'])

if os.path.exists(os.path.join(DATA_DIR, f'test/labels')) and os.path.exists(os.path.join(DATA_DIR, f'train/labels')):
    print('Labels detected, skipping conversion...')
else:
    print('Labels not detected, running conversion...')
    for tt in ['test', 'train']:
        # get label files
        files = glob.glob(os.path.join(DATA_DIR, f'{tt}/labels_raw/*.txt'))
        os.mkdir(os.path.join(DATA_DIR, f'{tt}/labels'))
        for file in files:
            labels = pd.read_csv(file, sep=' ',header=None)
            labels[[0]] = names[labels[[0]].values]
            print(labels)
            labels['zeros'] = 0
            labels[[0, 'zeros', 'zeros', 'zeros', 1, 2, 3, 4, 'zeros', 'zeros', 'zeros', 'zeros', 'zeros', 'zeros', 'zeros']].to_csv(file.replace('labels_raw', 'labels'), sep=' ', index=False, header=False)
        print(f'Converted {len(files)} {tt} label files')

# verification
num_training_images = len(os.listdir(os.path.join(DATA_DIR, "train/images")))
num_training_labels = len(os.listdir(os.path.join(DATA_DIR, "train/labels")))
num_testing_images = len(os.listdir(os.path.join(DATA_DIR, "test/images")))
print("Number of images in the train/val set. {}".format(num_training_images))
print("Number of labels in the train/val set. {}".format(num_training_labels))
print("Number of images in the test set. {}".format(num_testing_images))
