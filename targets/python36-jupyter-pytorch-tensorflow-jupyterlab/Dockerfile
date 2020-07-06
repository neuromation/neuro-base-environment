# ==================================================================
# module list
# ------------------------------------------------------------------
# python        3.6       (apt)
# jupyter       latest    (pip)
# jupyterlab    latest    (pip)
# pytorch       1.2.0     (pip)
# tensorflow    2.0.0-rc1 (pip)
# ==================================================================

FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04
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
        && \

    git clone https://github.com/Kitware/CMake ~/cmake && \
    cd ~/cmake && \
    git checkout release && \
    ./bootstrap && \
    make -j"$(nproc)" install && \

# ==================================================================
# python
# ------------------------------------------------------------------

    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        software-properties-common \
        && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        python3.6 \
        python3.6-dev \
        python3-distutils-extra \
        && \
    wget -O ~/get-pip.py \
        https://bootstrap.pypa.io/get-pip.py && \
    python3.6 ~/get-pip.py && \
    ln -s /usr/bin/python3.6 /usr/local/bin/python3 && \
    ln -s /usr/bin/python3.6 /usr/local/bin/python && \
    $PIP_INSTALL \
        setuptools \
        && \
    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        python3-tk \
        && \
    # Note: Pillow version fixed, see https://github.com/python-pillow/Pillow/issues/4130#issuecomment-570452778
    $PIP_INSTALL \
        numpy \
        scipy \
        pandas \
        cloudpickle \
        scikit-learn \
        matplotlib \
        Cython \
        Pillow==6.1 \
        && \

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
        numpy \
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
# pytorch
# ------------------------------------------------------------------

    $PIP_INSTALL \
        torch==1.2.0 \
        && \
    $PIP_INSTALL \
        torchvision==0.4.0 && \

# ==================================================================
# tensorflow
# ------------------------------------------------------------------

    $PIP_INSTALL \
        tensorflow-gpu==2.0.0 \
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

    $PIP_INSTALL awscli && \

# ==================================================================
# SSH
# ------------------------------------------------------------------

# Install openssh
  $APT_INSTALL openssh-server

# ==================================================================
# Apex for PyTorch mixed precision training
# ==================================================================

# Somehow Apex does not use releases, and current master fails to build
# (commit 1f2aa9156547377a023932a1512752c392d9bbdf on Apr 23, 2020).
# So we fix installation to the version Apr 21, 2020
RUN python -m pip install \
  -v --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" \
  git+https://github.com/NVIDIA/apex@2ec84ebdca59278eaf15e8ddf32476d9d6d8b904

# Setup environment for ssh session
RUN echo "export PATH=$PATH" >> /etc/profile && \
 echo "export LANG=$LANG" >> /etc/profile && \
 echo "export LANGUAGE=$LANGUAGE" >> /etc/profile && \
 echo "export LC_ALL=$LC_ALL" >> /etc/profile && \
 echo "export PYTHONIOENCODING=$PYTHONIOENCODING" >> /etc/profile

# Create folder for openssh fifos
RUN mkdir -p /var/run/sshd

# Disable password for root
RUN sed -i -re 's/^root:[^:]+:/root::/' /etc/shadow
RUN sed -i -re 's/^root:.*$/root::0:0:System Administrator:\/root:\/bin\/bash/' /etc/passwd

# Permit root login over ssh
RUN echo "Subsystem    sftp    /usr/lib/sftp-server \n\
PasswordAuthentication yes\n\
ChallengeResponseAuthentication yes\n\
PermitRootLogin yes \n\
PermitEmptyPasswords yes\n" > /etc/ssh/sshd_config

# ssh port
EXPOSE 22

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

# Create named pipe for stdout+stderr
ENV OUTPUT_PIPE "/output"

# Force the stdout and stderr streams to be unbuffered.
# Needed for correct work of tqdm via 'neuro exec'
ENV PYTHONUNBUFFERED 1

## Setup entrypoint
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh
ENTRYPOINT ["bash", "/entrypoint.sh"]
