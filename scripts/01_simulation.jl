#!/usr/bin/env julia

using Distributed #, SlurmClusterManager
using InteractiveUtils

#addprocs(SlurmManager(), exeflags="--project=test")
addprocs(30, exeflags="--project=.")

@everywhere using DrWatson
@everywhere using Dates
@everywhere @quickactivate "MSc_LMM_EEG"

@everywhere begin
    using Random
    using UnfoldSim

    """
    Simulate data based on parameterization
    """
    function simulate_data(params)
        # unpack parameters
        @unpack seed, nsubj, nitem, subj_btwn, item_btwn, both_win, β, σranef, σres, basis, fixationlen, formula, contrasts, noisetype, noiselevel = params

        # create random number generator from seed
        rng = MersenneTwister(seed)

        # init design, components & simulation
        design = ExperimentDesign(nsubj, nitem, subj_btwn, item_btwn, both_win)
        component = Component(basis, formula, contrasts, β, σranef, σres)
        simulation = Simulation(design, [component], length(basis), fixationlen, noisetype, noiselevel)

        # simulate
        eeg, onsets = UnfoldSim.simulate(deepcopy(rng), simulation)
        data, evts = UnfoldSim.convert(eeg, onsets, design)

        # prepare parameters for logging and saving
        d = @dict seed nsubj nitem β σranef σres noisetype noiselevel
        map!(x->replace(string(x), string(typeof(x)) => ""), values(d))

        # prepare saving
        sname = savename(d, "jld2")
        mkpath(datadir("test"))
        sdata = Dict("eeg" => eeg, "onsets" => onsets, "data" => data, "evts" => evts)

        # saving
        wsave(datadir("test", sname), sdata)

        # logging
        time = Dates.format(now(UTC), dateformat"yyyy-mm-dd HH:MM:SS")
        info = "$(myid()):$(gethostname()) : "
        @info savename(info*time, d; connector=" | ", equals=" = ", sort=false, digits=2)

        return true
    end

    """
    Overloading Base.string(...)
    """
    Base.string(::WhiteNoise) = "white"
    Base.string(::RedNoise) = "red"
    Base.string(::PinkNoise) = "pink"

end


# Include helper functions
include("../src/config.jl")

# Create config
args = args_parse()
cfg = config(args["filename"])

# Split config into list of parameter combinations
dicts = dict_list(cfg)
n_dicts = dict_list_count(cfg)

# Simulate data
@info "Simulating data... $(n_dicts)"
res = @time pmap(simulate_data, dicts)

# Removing workers
rmprocs(workers())

mis = findall(==(false), res)

if isempty(mis)
    @info "Successfully simulated $(n_dicts) simulations!"
else
    text = []
    for i in mis
        m = dicts[i]
        @unpack seed, nsubj, nitem, β, σranef, σres, noisetype, noiselevel = m
        d = @dict seed nsubj nitem β σranef σres noisetype noiselevel
        map!(x->replace(string(x), string(typeof(x)) => ""), values(d))
        push!(text, savename(d; connector=" | ", equals=" = ", sort=false, digits=2))
    end

    @warn "$(length(mis)) simulations mis! \n" * join(text, "\n")

end