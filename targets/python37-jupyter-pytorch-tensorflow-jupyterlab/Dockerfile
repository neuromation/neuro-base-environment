# ==================================================================
# module list
# ------------------------------------------------------------------
# python        3.7       (apt)
# jupyter       latest    (pip)
# jupyterlab    latest    (pip)
# pytorch       1.5.1     (docker-hub)
# tensorflow    2.2.0     (pip)
# ==================================================================

FROM pytorch/pytorch:1.5.1-cuda10.1-cudnn7-devel
ENV LANG C.UTF-8
RUN APT_INSTALL="apt-get install -y --no-install-recommends" && \
    PIP_INSTALL="python -m pip --no-cache-dir install --upgrade" && \
    GIT_CLONE="git clone --depth 10" && \

    rm -rf /var/lib/apt/lists/* \
           /etc/apt/sources.list.d/cuda.list \
           /etc/apt/sources.list.d/nvidia-ml.list && \

    apt-get update && \

# ==================================================================
# tools
# ------------------------------------------------------------------

    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        apt-utils \
        build-essential \
        ca-certificates \
        curl \
        git \
        libssl-dev \
        rsync \
        unrar \
        unzip \
        vim \
        wget \
        libncurses5-dev \
        libncursesw5-dev \
        cmake \
        nano \
        tmux \
        htop \
        && \

# ==================================================================
# python
# ------------------------------------------------------------------
    $PIP_INSTALL \
        numpy \
        scipy \
        pandas \
        cloudpickle \
        scikit-learn \
        matplotlib \
        Cython \
        Pillow \
        && \
        
    # OpenCV
    $APT_INSTALL libsm6 libxext6 libxrender-dev && \ 

# ==================================================================
# jupyter
# ------------------------------------------------------------------

    $PIP_INSTALL \
        jupyter \
        && \

# ==================================================================
# pytorch-utils
# ------------------------------------------------------------------

    $APT_INSTALL \
        python3-yaml \
        && \

    $PIP_INSTALL \
        future \
        protobuf \
        typing \
        && \

# ==================================================================
# jupyterlab
# ------------------------------------------------------------------
    # To pass test `jupyter lab build` (jupyterlab extensions), it needs nodejs>=12
    # See instructions https://github.com/nodesource/distributions/blob/master/README.md#installation-instructions
    curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
    $APT_INSTALL \
        nodejs \
        && \

    $PIP_INSTALL \
        jupyterlab \
        && \

# ==================================================================
# tensorboard
# ------------------------------------------------------------------

    $PIP_INSTALL \
        tensorboard \
        && \

# ==================================================================
# tensorboardX
# ------------------------------------------------------------------

    $PIP_INSTALL \
        tensorboardX \
        && \

# ==================================================================
# neuromation
# ------------------------------------------------------------------

    $PIP_INSTALL \
        neuromation \
        && \

# ==================================================================
# wandb
# ------------------------------------------------------------------

    $PIP_INSTALL \
        wandb \
        && \

# ==================================================================
# tqdm
# ------------------------------------------------------------------

    $PIP_INSTALL \
        tqdm \
        && \

# ==================================================================
# tensorflow
# ------------------------------------------------------------------

    $PIP_INSTALL \
        tensorflow==2.2.0 \
        && \

# ==================================================================
# gsutils
# ------------------------------------------------------------------

    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" >> /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
    apt-get -y update && \

  $APT_INSTALL google-cloud-sdk && \

  # Python API:
  $PIP_INSTALL google-cloud-storage && \

# ==================================================================
# aws
# ------------------------------------------------------------------

    $PIP_INSTALL awscli

# ==================================================================
# Apex for PyTorch mixed precision training
# ==================================================================

# Somehow Apex does not use releases, and current master fails to build
# (commit 1f2aa9156547377a023932a1512752c392d9bbdf on Apr 23, 2020).
# So we fix installation to the version Apr 21, 2020
RUN python -m pip install \
  -v --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" \
  git+https://github.com/NVIDIA/apex@2ec84ebdca59278eaf15e8ddf32476d9d6d8b904

# ==================================================================
# Documentation notebook
# ------------------------------------------------------------------
RUN mkdir -p /var/notebooks
COPY files/var/notebooks/README.ipynb /var/notebooks


# ==================================================================
# config & cleanup
# ------------------------------------------------------------------

RUN ldconfig && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/* ~/*

EXPOSE 8888 6006

# Force the stdout and stderr streams to be unbuffered.
# Needed for correct work of tqdm via 'neuro exec'
ENV PYTHONUNBUFFERED 1

WORKDIR /project

## Setup entrypoint
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh
ENTRYPOINT ["bash", "/entrypoint.sh"]
