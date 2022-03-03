export OMPI4_CONTAINER=ompi4-config.sif
export CUDA_BASE_IMAGE="nvidia/cuda:11.4.2-cudnn8-devel-ubuntu18.04"
export SINGULARITYENV_VERBS=without-verbs

export SINGULARITYENV_TENSORFLOW_VERSION=2.7.0
export SINGULARITYENV_PYTORCH_VERSION=1.10.0+cu113
export SINGULARITYENV_PIP_CMD_1="pip install torch==${SINGULARITYENV_PYTORCH_VERSION} torchvision==0.11.1+cu113 torchaudio==0.10.0+cu113 -f https://download.pytorch.org/whl/cu113/torch_stable.html"
export SINGULARITYENV_PIP_CMD_2="pip install mxnet-cu112 tensorflow-gpu==${SINGULARITYENV_TENSORFLOW_VERSION} keras h5py filelock matplotlib scikit-learn"
export SINGULARITYENV_LDCONFIG_PATH="/usr/local/cuda-11.4/targets/x86_64-linux/lib/stubs"
export SINGULARITYENV_PIP_CMD_3="HOROVOD_GPU_ALLREDUCE=NCCL HOROVOD_WITH_MXNET=1 HOROVOD_WITH_TENSORFLOW=1 HOROVOD_WITH_PYTORCH=1 pip install --no-cache-dir horovod "
