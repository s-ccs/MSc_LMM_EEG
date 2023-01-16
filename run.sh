#!/bin/bash -l

#-----------------------
# Job info
#-----------------------

#SBATCH --job-name=TEST

# by default, slurm makes "slurm-%j.out" files w/ output. uncomment to change
#SBATCH --output ./output/slurm-%j.out

#-----------------------
# Resource allocation
#-----------------------

#SBATCH --time=2-00:00:00     # in d-hh:mm:ss
#SBATCH --nodes=6         # single node
#SBATCH --ntasks-per-node=128
#SBATCH --partition=cpu # partition

##SBATCH --mem=90000       # uncomment to max out RAM
##SBATCH --mem-per-cpu=1990
##SBATCH --cpus-per-task=10

hostname

echo "Starting job!!! ${SLURM_JOB_ID}"

# print out environment variables related to SLURM_NTASKS
julia -e 'println("\n"); [println((k,ENV[k],)) for k in keys(ENV) if occursin("SLURM_NTASKS",k)]; println("\n");'

echo $(julia --version)

#export JULIA_NUM_THREADS=$SLURM_CPUS_PER_TASK


# run the script
#julia --project=. --optimize=3 scripts/00_run.jl $1 $2
julia --project=. --optimize=3 scripts/11_run.jl $1 $2
#julia --project=. --optimize=3 scripts/33_run.jl $1 $2
#julia --project=. --optimize=3 scripts/threads.jl


#julia --project=. --optimize=3 scripts/sanity_check.jl $1 $2
#julia --project=. --optimize=3 scripts/test.jl $1 $2
