# JamCam Workflow via NVIDIA-TAO

This workflow reproduces a more accessible transfer-trained model similar to that trained for Turing's [Project Odysseus](https://www.turing.ac.uk/research/research-projects/project-odysseus-understanding-london-busyness-and-exiting-lockdown) as described in [arXiv:2012.07751](https://arxiv.org/abs/2012.07751). The process involves tuning a [YoloV4](https://arxiv.org/pdf/2004.10934.pdf) implementation with NVIDIA's Train, Adapt and Optimize platform ([TAO](https://developer.nvidia.com/tao)).

## Getting Started

This guide assumes a hardware dependancy of at least one GPU and a likely goal for execution within an academic HPC environment. 

### Installation

The included [Vagrantfile](../../Vagrantfile) in the base of this repository will generate suitable VM with all dependencies. If virtualising this step, skip to [Building Images](#building-the-singularity-image). Alternatively, the base dependencies are Python 3.10, Go, and Singularity/Apptainer.

Python installation instructions can be followed on the [official page](https://www.python.org/downloads/), although creation of a python virtual environment, such as [miniconda3](https://docs.conda.io/en/latest/miniconda.html), is highly advised. Full Apptainer/Singularity configuration is non-trivial process but installation is recommended following [official guidance](https://apptainer.org/docs/admin/main/installation.html). 

The rest of installation document the creation of a [Singularity container](https://sylabs.io/guides/3.5/user-guide/index.html), from a converted nvidia-tao image and installation of additional dependencies. The singularity container will allow you to call all the scripts from the project. It's recommended this is done locally given most HPC platforms expect elevated privileges to build on login nodes.

### Building the Singularity Image

To build a singularity container use the [build script](build.sh) in this directory, (requires `Python >= 3.10):
```bash
./build.sh
```
The script will generate an `nvidia-tao.def` definition file and attempt to build it directly or as `--fakeroot` if permissions allow.

### Example Usage

To begin, it is expect that a dataset matching CVAT or TAO specification, e.g.

```bash
# (object_id)  (loc_x)  (loc_y)  (width) (height)
            2 0.774148 0.437500 0.071023 0.083333
            2 0.693182 0.487847 0.073864 0.100694
            2 0.903409 0.652778 0.113636 0.152778
            ⋮      ⋮        ⋮        ⋮        ⋮
```

This can be collected from the jamcam sample with

```bash
singularity exec --nv nvidia-tao.sif --download
```

After which, is it best to verify data collection occured and decompressed into expected locations. Then we may generate the validation dataset with default parameters,

```bash
singularity exec --nv nvidia-tao.sif --gen-valid
```

It is necessary to now convert these labels into tfrecords,

```bash
singularity exec --nv nvidia-tao.sif --convert-data
```

Finally permitting readiness to begin training with default parameters,

```bash
singularity exec --nv nvidia-tao.sif --train
```

Model training parameters may be updated in the configuration file: `yolo_v4_train_resnet18_jamcam`.

### Direct Usage
All training stages may be executed within the resultant container directly with 

```bash
singularity exec --nv nvidia-tao.sif --all
```

## Detailed options

The workspace directory is the primary area of all interaction, this is defaultly located at `\workspace\` within the container. To expose this directory instead, remove the comment in ... and mount a local directory with 

```bash
singularity exec --nv --bind <your-workspace>:/workspace/ nvidia-tao.sif <options>
```

Each stage may be completed independently (assuming prior stage completion):

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
<!-- ```[TODO: change paths for verification]``` -->
<!-- Assuming non quantization aware training (QAT) -->

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

## Funders
Lloyd's Registrar Foundation, Warwick Impact Fund

## Licence
The code is under the GNU General Public License Version 3.