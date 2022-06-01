# JamCam Workflow via NVIDIA-TAO

This workflow reproduces a transfer-trained model similar to that trained for Turing's [Project Odysseus](https://www.turing.ac.uk/research/research-projects/project-odysseus-understanding-london-busyness-and-exiting-lockdown) as described in [arXiv:2012.07751](https://arxiv.org/abs/2012.07751).

## Getting Started

### General

To get going, first a [Singularity container](https://sylabs.io/guides/3.5/user-guide/index.html) is built converting an nvidia-tao image and installs additional dependencies. The singularity container will allow you to call all the scripts from the project. It's recommended this is done locally given most HPC platforms expect elevated privileges to build on login nodes.



### Building the Singularity Image

To build a singularity container use the [build script](build.sh) in this directory, requires `Python >= 3.10`:
```bash
./build.sh
```
The script will generate an `nvidia-tao.def` definition file and attempt to build it directly or as `--fakeroot` if permissions allow.


### Direct Usage
All training stages may now be executed within the resultant container directly with 

```bash
singularity exec --nv --bind <your-workspace>:/workspace/ nvidia-tao.sif jamcam/entry.sh --all
```
```[TODO: just call directly on the entry point]```  

Alternatively, each stage may be completed independently (assuming prior stage completion):

```
usage singularity exec --nv --bind <your-workspace>:/workspace/ nvidia-tao.sif --STAGE

options:
    --download      Downloads required model and datasets
    --verify        Verification of dataset accessibility, outputs number of train/test/validation samples.
	--gen-valid     Generate validation set with default parameters (10% split)
	--tune-bdb      Tune bounding box
	--convert-data  Convert dataset to tfrecords (yolo_v4 file format)
	--train         Train with configuration specified in configuration file
	--eval          Evaluate model
	--vis           Generate default visualisations
	--export        Export to alternative data types (default fp32)
```
```[TODO: change paths for verification]```
<!-- Assuming non quantization aware training (QAT) -->

Training parameters may be updated in the configuration file: `yolo_v4_train_resnet18_jamcam`.


## Detailed options

### Directory structure
```
workspace
├── data
│   ├── task_jamcams_groundtruth.zip
│   ├── test
│   │   ├── images
│   │   ├── labels
│   │   ├── labels_raw
│   │   └── tfrecords
│   ├── tlt_resnet18_ssd_1.zip
│   ├── train
│   │   ├── images
│   │   ├── labels
│   │   ├── labels_raw
│   │   └── tfrecords
│   └── val
│       ├── images
│       ├── labels
│       └── tfrecords
├── experiment
├── pretrained_resnet18
└── specs
    ├── yolo_v4_tfrecords_jamcam_train.txt
    ├── yolo_v4_tfrecords_jamcam_val.txt
    └── yolo_v4_train_resnet18_jamcam.txt
```

### Alternate TAO Versions

Specific versions of Nvidia TAO containers can be requested by changing the `TAO_VERSION` parameter in the script. Version availability is accessed from the [template generator](../../base_containers/nvidia-tao/template.py):

```bash
usage: template.py [-h] [{all,newest,3.21.11,3.21.12,3.21.08}]

Template Nvidia-tao definition files

positional arguments:
  {all,newest,3.21.11,3.21.12,3.21.08}
                        Tao version
options:
  -h, --help            show this help message and exit
```

### Alternate validation dataset split
Parameters for validation dataset generation may set calling the [generate script](jamcam/generate_val_dataset.py) directly:

For example, for a 15% validation split:
```bash
 python3 jamcam/generate_val_dataset.py 
    --input_image_dir=$DATA_DOWNLOAD_DIR/train/images \
	--input_label_dir=$DATA_DOWNLOAD_DIR/train/labels \
	--output_dir=$DATA_DOWNLOAD_DIR/val \
    --val_split=15
```

```bash
usage: generate_val_dataset.py [-h] --input_image_dir INPUT_IMAGE_DIR --input_label_dir INPUT_LABEL_DIR --output_dir OUTPUT_DIR [--val_split VAL_SPLIT]

Generate val dataset

optional arguments:
  -h, --help            show this help message and exit
  --input_image_dir INPUT_IMAGE_DIR
                        Input directory to training dataset images.
  --input_label_dir INPUT_LABEL_DIR
                        Input directory to training dataset labels.
  --output_dir OUTPUT_DIR
                        Ouput directory to val dataset.
  --val_split VAL_SPLIT
                        Percentage of training dataset for generating val dataset
```

## Platform-specific Notes

Oddities on HPC plats

Containerisation explanations: [JADE](http://docs.jade.ac.uk/en/latest/jade/containers.html#singularity-containers), [Baskerville](https://docs.baskerville.ac.uk/singularity/)

### WSL2
For local operation and development, sometimes WSL2 is preferred. At time of writing, in order for Singularity to access the GPU through WSL2, both `--nv` and `--nvccli` flags must be set as described in this blogpost:
[CUDA GPU Containers on Windows with WSL2](https://sylabs.io/2022/03/wsl2-gpu/).

## Benchmarking

## HPC Testing
This workflow has been tested on the following UK HPC research platforms:
 - PEARL ([info](https://www.turing.ac.uk/research/asg/pearl), [docs](https://pearl-cluster.readthedocs.io//))
 - JADE ([info](https://www.jade.ac.uk/), [docs](https://docs.jade.ac.uk/))
 - Baskerville ([info](https://www.baskerville.ac.uk/), [docs](https://docs.baskerville.ac.uk/))


Example iterative shells

```bash
# JADE
srun -I --pty -t 0-10:00 --gres gpus:1 -p small singularity ~/repos/AI-workflows/workflows/jamcam/nvidia-tao.sif
```