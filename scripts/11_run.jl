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

# Imports on every worker
@everywhere using DrWatson
@everywhere using Dates
@everywhere @quickactivate "MSc_LMM_EEG"
@everywhere using MixedModels: @formula, fit, MixedModel, fixefnames
@everywhere using CairoMakie
@everywhere using DataFrames
@everywhere begin
    using Random
    using Unfold
    using DSP
    using UnfoldSim
    using StableRNGs
    using Statistics
    using HypothesisTests
    using MixedModelsSim
    using MixedModelsPermutations
    using DelimitedFiles
end

# second cmd line argument = path/to/datadir
dir =  (isassigned(ARGS, 2) ? ARGS[2] : "data")
@everywhere dir = $(dir)

@everywhere begin
    datadir(args...) = projectdir(dir, args...)
end


#############
# FUNCTIONS 
#############

@everywhere begin
    function power(pvalues)
        return length(pvalues[pvalues.<0.05]) / length(pvalues) * 100
    end

    function pvalue((data, evts, data_epoch, times), model; quicklmm=true, timeexpanded=false)
        # average over window
        window = 89:89
        avg = mean(data_epoch[:, window, :], dims=2)
        evts.dv = [avg...]

        # two stage
        if model=="twostage" && !timeexpanded
            gd = groupby(evts, [:subject, :cond])
            mv = combine(gd, [:dv] .=> mean)
            x = filter(:cond => ==("A"), mv).dv_mean
            y = filter(:cond => ==("B"), mv).dv_mean
            pvalue = HypothesisTests.pvalue(OneSampleTTest(x, y))

        elseif model=="lmm" && !timeexpanded
            fm = @formula(dv ~ 1 + cond + (1 + cond | subject))
            fm1 = fit(MixedModel, fm, evts, progress=false)
            #fm1.optsum

            if quicklmm
                pvalue = fm1.pvalues[indexin(["cond: B"], fixefnames(fm1))[1]]
            
            elseif !quicklmm
                H0 = coef(fm1) # H0 (slope of stimType=0 ?)
                H0[2] = 0
                pvalue = try
                    perm = permutation(StableRNG(42), 1000, fm1; β=H0, hide_progress=true)
                    pvalues = permutationtest(perm, fm1)
                    getproperty(pvalues, Symbol("cond: B"))
                catch e
                    @warn e seed nsubj nitem β σranef σres noisetype noiselevel
                    missing
                end
            end
        end

        return pvalue
    end


    function sim(nsubj, nitem, seed, params)

        # unpack parameters
        @unpack subj_btwn, item_btwn, both_win, β, σranef, σres, basis, fixationlen, formula, contrasts, noisetype, noiselevel = params

        # create random number generator
        rng = MersenneTwister(seed)

        # init design, components & simulation
        design = ExperimentDesign(nsubj, nitem, subj_btwn, item_btwn, both_win)
        component = Component(basis, formula, contrasts, β, σranef, σres)
        simulation = Simulation(design, [component], length(basis), fixationlen, noisetype, noiselevel)

        # simulate
        eeg, onsets = UnfoldSim.simulate(deepcopy(rng), simulation)
        data, evts = UnfoldSim.convert(eeg, onsets, design)

        # epoch data
        τ = (-0.1, 1.2) #QUICKFIX
        sfreq = 256 #QUICKFIX
        data_epoch, times = Unfold.epoch(data=data, tbl=evts, τ=τ, sfreq=sfreq)
        
        return data, evts, data_epoch, times
    end


    function run(params)
        # select outer loop iteration parameters
        seed = pop!(params, "seed")
        nsubjs = pop!(params, "nsubj")
        nitems = pop!(params, "nitem")
        models = pop!(params, "models")
        
        # create and save power matrices
        for nsubj in nsubjs, nitem in nitems, model in models
            
            # compute power for specific combination
            P = power(pvalue.(sim.(nsubj, nitem, seed, (params,)), model))
            
            # prepare parameters for logging, loading and saving
            @unpack β, σranef, σres, noisetype, noiselevel = params
            d = @dict nsubjs nitems model β σranef σres noisetype noiselevel
            map!(x->replace(string(x), string(typeof(x)) => ""), values(d))

            # save to csv
            sname = savename(d, "csv")
            writedlm(datadir("power", sname),  P, ',')
        end
    end

    """
    Overloading Base.string(...)
    """
    Base.string(::WhiteNoise) = "white"
    Base.string(::RedNoise) = "red"
    Base.string(::PinkNoise) = "pink"

end


#############
# MAIN PART
#############

# Include helper functions
include("../src/config.jl")

# Create config
cfg = config(filename)

# Split config into list of parameter combinations
dicts = dict_list(cfg)
n_dicts = dict_list_count(cfg)

# Simulate data & compute pvalues
@info "Creating power matrices... $(n_dicts)"
flush(stderr)
pmap(run, parameter_list)
