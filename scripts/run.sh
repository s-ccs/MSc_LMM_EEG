#-----------------------
# Resource allocation
#-----------------------

#SBATCH --time=2-00:00:00           
#SBATCH --nodes=6                   
#SBATCH --ntasks-per-node=128
#SBATCH --partition=cpu             

##SBATCH --mem=90000            
##SBATCH --mem-per-cpu=1990
##SBATCH --cpus-per-task=10


# log hostname and job id
echo "Hostname:" $(hostname)
echo "Job ID: ${SLURM_JOB_ID}"

# print out environment variables related to SLURM_NTASKS
julia -e 'println("\n"); [println((k,ENV[k],)) for k in keys(ENV) if occursin("SLURM_NTASKS",k)]; println("\n");'

# print julia version
echo "Julia version:" $(julia --version)

# run the script
julia --project=. --optimize=3 scripts/01_run.jl $1 $2