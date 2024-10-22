#!/bin/bash
#SBATCH -e slurm.err
#SBATCH --mem=4G
singularity run --cleanenv -B /hpc/group/egnerlab:/mnt \
/hpc/group/egnerlab/my_images/fmriprep-20.1.1.simg \
/mnt/decodCC.01_BIDS/Nifti \
/mnt/decodCC.01_BIDS/Preprocessed \
participant \
--fs-license-file /mnt/freesurfer.txt \
--participant-label 03 \
--dummy-scans 4 