#!/bin/bash
#SBATCH --job-name=singletons
#SBATCH --output=%x-%j.out
#SBATCH --mail-user=pschloss@umich.edu
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --partition=standard
#SBATCH --account=pschloss0
#SBATCH --time=100:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=45g



### Conda environment:
source ~/miniconda3/etc/profile.d/conda.sh
conda activate singletons

### Run script
time snakemake --profile config/slurm
