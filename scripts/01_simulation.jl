#!/usr/bin/env julia

using Distributed#, SlurmClusterManager
#addprocs(SlurmManager(), exeflags="--project=test")
addprocs(6)

@everywhere using DrWatson
@everywhere using Dates

@everywhere begin
    @quickactivate "MSc_LMM_EEG"
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
        @show d
        map!(x->replace(string(x), string(typeof(x)) => ""), values(d))

        # logging
        time = Dates.format(now(UTC), dateformat"yyyy-mm-dd HH:MM:SS")
        @info savename(time, d; connector=" | ", equals=" = ", sort=false, digits=2)

        # add new values to dictionary params
        ks = ["eeg", "onsets", "data", "evts"]
        vs = [eeg, onsets, data, evts]
        foreach(((k, v), ) -> params[k] = v, zip(ks, vs))

        # saving
        sname = savename(d, "jld2")
        mkpath(datadir("simulation"))
        wsave(datadir("simulation", sname), params)
       
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

# Simulate data
@info "Simulating data..."
res = pmap(simulate_data, dicts)