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

        return params
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
res = pmap(simulate_data, dicts)

# Removing workers
rmprocs(workers())

# check for missing
dicts = [filter(k->k.first ∉ ["formula", "contrasts"], d) for d in dicts]
res = [filter(k->k.first ∉ ["formula", "contrasts"], r) for r in res]
missing = filter(!in(res), dicts)

# result
if isempty(missing)
    @info "Successfully simulated $(n_dicts) simulations!"
else
    @warn "$(length(missing)) simulations missing!"
    for m in dicts
        @unpack seed, nsubj, nitem, β, σranef, σres, noisetype, noiselevel = m
        d = @dict seed nsubj nitem β σranef σres noisetype noiselevel
        map!(x->replace(string(x), string(typeof(x)) => ""), values(d))
        @warn savename(d; connector=" | ", equals=" = ", sort=false, digits=2)
    end
end


