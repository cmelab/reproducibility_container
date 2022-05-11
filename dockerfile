FROM cmelab/gpuconda:latest

ENV CONDA_OVERRIDE_CUDA=10.2

RUN conda update -n base -c defaults conda && \
    conda install mamba -n base -c conda-forge && \
    mamba install -c conda-forge -c bioconda cassandra=1.2.5 cudatoolkit=10.2 gromacs=2020.6 hoomd=3*=*gpu* lammps
