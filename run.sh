#!/bin/bash -l

#-----------------------
# Job info
#-----------------------

#SBATCH --job-name=TEST

# by default, slurm makes "slurm-%j.out" files w/ output. uncomment to change
#SBATCH --output ./output/slurm-%j.out
##SBATCH --error ./output/slurm-%j.error

#-----------------------
# Resource allocation
#-----------------------

#SBATCH --time=00:30:00     # in d-hh:mm:ss
#SBATCH --nodes=3         # single node
##SBATCH --ntasks=4         # number of virtual cores
#SBATCH --ntasks-per-node=40
#SBATCH --partition=dev_multiple # partition

##SBATCH --mem=90000       # uncomment to max out RAM
##SBATCH --mem-per-cpu=1990

hostname

echo "Starting job!!! ${SLURM_JOB_ID}"

# print out environment variables related to SLURM_NTASKS
julia -e 'println("\n"); [println((k,ENV[k],)) for k in keys(ENV) if occursin("SLURM_NTASKS",k)]; println("\n");'

echo $(julia --version)

# run the script
julia --project=. --optimize=3 scripts/00_run.jl $1
