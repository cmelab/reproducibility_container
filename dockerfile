FROM cmelab/gpuconda:latest

ENV CONDA_OVERRIDE_CUDA=10.2

ADD . environment.yml

RUN conda update -n base -c defaults conda && \
    conda install mamba -n base -c conda-forge && \
    mamba install -c conda-forge hoomd=3*=*gpu* cudatoolkit=10.2 && \
    mamba env update -n base -f environment.yml
