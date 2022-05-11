FROM nvidia/cuda:10.2-devel 

# Install system dependencies
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# nvidia/cuda repos are currently rotating their gpg keys
# https://forums.developer.nvidia.com/t/notice-cuda-linux-repository-key-rotation/212771/8
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
ENV DISTRO=ubuntu1804
ENV ARCH=x86_64
RUN sh -c 'echo "APT { Get { AllowUnauthenticated \"1\"; }; };" > /etc/apt/apt.conf.d/99allow_unauth'
RUN apt -o Acquire::AllowInsecureRepositories=true -o Acquire::AllowDowngradeToInsecureRepositories=true update
RUN apt-get install -y curl wget
RUN apt-key del 7fa2af80
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/$DISTRO/$ARCH/cuda-keyring_1.0-1_all.deb
RUN dpkg -i cuda-keyring_1.0-1_all.deb
RUN rm -f /etc/apt/sources.list.d/cuda.list /etc/apt/apt.conf.d/99allow_unauth cuda-keyring_1.0-1_all.deb
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A4B469963BF863CC F60F4B3D7FA2AF80

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        cmake \
        curl \
        git \
        libtbb-dev \
        libgl1-mesa-dev \
    && apt-get clean

# Install miniconda
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

ENV PATH /opt/conda/bin:$PATH

# By default running container starts bash shell
CMD [ "/bin/bash" ]

ENV CONDA_VERSION=py38_4.9.2
ENV CONDA_MD5=122c8c9beb51e124ab32a0fa6426c656

RUN curl -s https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh -o miniconda.sh && \
    echo "${CONDA_MD5}  miniconda.sh" > miniconda.md5 && \
    if ! md5sum --status -c miniconda.md5; then exit 1; fi && \
    mkdir -p /opt && \
    sh miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh miniconda.md5 && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy

WORKDIR /opt

# Make RUN commands use `bash --login`: -- fixes conda init
# https://pythonspeed.com/articles/activate-conda-dockerfile/
SHELL ["/bin/bash", "--login", "-c"]

# Prevent python from loading packages from outside the container
# default empty pythonpath
ENV PYTHONPATH=/ignore/pythonpath

ENV PYTHONUSERBASE=/ignore/pythonpath

ENV CONDA_OVERRIDE_CUDA=10.2

ADD . environment.yml

RUN conda update -n base -c defaults conda && \
    conda env update -n base -f environment.yml && \
    conda clean --all --yes -f
