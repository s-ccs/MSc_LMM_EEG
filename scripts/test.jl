#!/usr/bin/env julia

using Distributed#, SlurmClusterManager

addprocs(4, exeflags="--project=.")


@everywhere using DrWatson
@everywhere @quickactivate "MSc_LMM_EEG"
@everywhere ARGS

dir =  (isassigned(ARGS, 2) ? ARGS[2] : "data")
@everywhere dir = $(dir)

@everywhere begin
    datadir(args...) = projectdir(dir, args...)
end

@everywhere begin
    function a(i)
        @info datadir()
    end
end

# test
@show ARGS
pmap(a, 1:10)

# Removing workers
rmprocs(workers())

