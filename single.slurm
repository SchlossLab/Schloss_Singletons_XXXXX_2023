#!/bin/bash
#SBATCH --job-name=run_single
#SBATCH --output=%x-%j.out
#SBATCH --mail-user=pschloss@umich.edu
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --partition=standard
#SBATCH --account=pschloss1
#SBATCH --time=300:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=12g



### Conda environment:
source ~/miniconda3/etc/profile.d/conda.sh
conda activate singletons

### Run script
time workflow/scripts/render_manuscript.R
