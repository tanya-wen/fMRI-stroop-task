#!/bin/bash
#SBATCH -e slurm_%A_%a.err
#SBATCH -o slurm_%A_%a.out
#SBATCH -p common
#SBATCH -a 1-30
echo $SLURM_ARRAY_TASK_ID
./run_sing.sh
