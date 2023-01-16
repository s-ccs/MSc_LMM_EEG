#!/usr/bin/env julia

using Distributed

# config dependend on normal / slurm cluster
const SLURM = "SLURM_JOBID" in keys(ENV)
SLURM && using SlurmClusterManager

if SLURM
    addprocs(SlurmManager(), exeflags="--project=.")
else
    addprocs(2;exeflags="--project=.")
end


@everywhere begin
    function task_D(i)
        @info "Threads" myid() i Threads.nthreads() 
    end
end

pmap(task_D, 1:10)
