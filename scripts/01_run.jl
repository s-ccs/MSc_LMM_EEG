#!/usr/bin/env julia

using Distributed

# config dependend on normal / slurm cluster
const SLURM = "SLURM_JOBID" in keys(ENV)
SLURM && using SlurmClusterManager

# use manager if on slurm cluster
if SLURM
    addprocs(SlurmManager(), exeflags="--project=.")
else
    addprocs(2;exeflags="--project=.")
end

# Imports on every worker
@everywhere using DrWatson
@everywhere using Dates
@everywhere @quickactivate "MSc_LMM_EEG"
@everywhere using MixedModels: @formula, fit, refit!, MixedModel, fixefnames
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
    """
    Compute power for given array of pvalues (Significance level alpha = 0.05)
    """
    function power(pvalues)
        return length(pvalues[pvalues.<0.05]) / length(pvalues) * 100
    end


    """
    Compute the pvalues for given data and model
    """
    function pvalue((data, evts, data_epoch, times), model; quicklmm=false, timeexpanded=false)
        # average over window
        window = 87:91
        avg = mean(data_epoch[:, window, :], dims=2)
        evts.dv = [avg...]

        # two stage approach
        if model=="twostage" && !timeexpanded
            gd = groupby(evts, [:subject, :cond])
            mv = combine(gd, [:dv] .=> mean)
            x = filter(:cond => ==("A"), mv).dv_mean
            y = filter(:cond => ==("B"), mv).dv_mean
            pvalue = HypothesisTests.pvalue(OneSampleTTest(x, y))

        # linear mixed model approach
        elseif startswith(model, "lmm") && !timeexpanded
            fm = @formula(dv ~ 1 + cond + (1 + cond | subject)) 
            fm1 = MixedModel(fm, evts)
            fm1.optsum.maxtime = 2
            refit!(fm1, progress=false)

            # linear mixed model approach with Z-statistic
            if model=="lmmquick"
                pvalue = fm1.pvalues[indexin(["cond: B"], fixefnames(fm1))[1]]
            
            # linear mixed model approach with permutation testing
            elseif model=="lmmperm"
                H0 = coef(fm1) 
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


    """
    Simulate data based on given parameters
    """
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


    function run_iteration(nsubj, nitem, seed, params, model)
        p = @time "Compute power" power(pvalue.(sim.(nsubj, nitem, seed, (params,)), model))
        return p
    end


    function run(params)
        # select outer loop iteration parameters
        seed = pop!(params, "seed")
        nsubjs = pop!(params, "nsubj")
        nitems = pop!(params, "nitem")
        models = pop!(params, "models")
        
        # create and save power matrices
        for model in models
	        pa = deepcopy(params)
            @info "Parameters:" seed nsubjs nitems model 
            
            # compute power for specific combination
            P = @time "Create power matrix" pmap(((nsubj, nitem),)->run_iteration(nsubj, nitem, seed, pa, model), reverse([Iterators.product(nsubjs, nitems)...]))
            P = reshape(reverse(P), (length(nsubjs), length(nitems)))

            # prepare parameters for logging, loading and saving
            @unpack β, σranef, σres, noisetype, noiselevel = pa
            d = @dict nsubjs nitems model β σranef σres noisetype noiselevel
            map!(x->replace(string(x), string(typeof(x)) => ""), values(d))

	        try
                # create plot
                f = plot(P, nsubjs, nitems, pa, model)

                # save P contour plot to png 
                mkpath(datadir("plots"))
                fname = savename(d, "png")
                save(datadir("plots", fname), f)
            finally
                # save to csv
                sname = savename(d, "csv")
                mkpath(datadir("power"))
                @time "Saving" writedlm(datadir("power", sname),  P, ',')
            end

            # flush
            flush(stdout)
            flush(stderr)
        end
    end

    """
    Overloading Base.string(...) for file name creation
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
cfg = config(ARGS[1])

# Split config into list of parameter combinations
dicts = dict_list(cfg)
n_dicts = dict_list_count(cfg)

# Simulate data & compute pvalues
@info "Creating power matrices... $(n_dicts)"
flush(stderr)
@time "All" for p in dicts
    run(p)
end
