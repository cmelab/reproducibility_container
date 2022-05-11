FROM cmelab/gpuconda:latest

ENV CONDA_OVERRIDE_CUDA=10.2

RUN conda update -n base -c defaults conda && \
    conda install mamba -n base -c conda-forge && \
    mamba install -c conda-forge cassandra=1.2.5 constrainmol cudatoolkit=10.2 ele foyer>=0.9.4 freud gmso gromacs=2020.6 gsd h5py hoomd=3*=*gpu* jinja2 lammps mbuild>=0.13.0 mdtraj mosdef_cassandra numpy openmm>=7.6 packmol>=18 panedr parmed>=3.4.3 pymbar python rdkit signac signac-flow unyt
