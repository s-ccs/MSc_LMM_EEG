#!/usr/bin/env julia

using Distributed#, SlurmClusterManager
#addprocs(SlurmManager(), exeflags="--project=test")
addprocs(6)

@everywhere using DrWatson
@everywhere using Dates

@everywhere begin
    @quickactivate "MSc_LMM_EEG"
    using Random
    using Unfold
    using UnfoldSim
    using DataFrames
    using HypothesisTests

    # include files
    include("../src/analysis.jl")

    """
    Epoch simulated data given parameters
    """
    function epoch_data(params)
        # unpack parameters
        @unpack seed, nsubj, nitem, β, σranef, σres, noisetype, noiselevel = params

        # prepare parameters for logging, loading and saving
        d = @dict seed nsubj nitem β σranef σres noisetype noiselevel
        map!(x->replace(string(x), string(typeof(x)) => ""), values(d))

        # load simulation for parameters
        fname = savename(d, "jld2")
        params = wload(datadir("simulation", fname))
        @unpack data, evts = params

        # epoch data
        τ = (-0.1, 1.2) #QUICKFIX 
        sfreq = 256 #QUICKFIX 
        data_epoch, times = Unfold.epoch(data=data, tbl=evts, τ=τ, sfreq=sfreq)

        # logging
        time = Dates.format(now(UTC), dateformat"yyyy-mm-dd HH:MM:SS")
        @info savename(time, d; connector=" | ", equals=" = ", sort=false, digits=2)

        # add new values to dictionary params
        ks = ["data_epoch", "times"]
        vs = [data_epoch, times]
        foreach(((k, v), ) -> params[k] = v, zip(ks, vs))

        # saving
        sname = savename(d, "jld2")
        mkpath(datadir("epochs"))
        wsave(datadir("epochs", sname), params)

        return true
    end

    """
    Analysis two stage
    """
    function analysis_2stage(params)
        # unpack parameters
        @unpack seed, nsubj, nitem, β, σranef, σres, noisetype, noiselevel = params

        # prepare parameters for logging, loading and saving
        d = @dict seed nsubj nitem β σranef σres noisetype noiselevel
        map!(x->replace(string(x), string(typeof(x)) => ""), values(d))

        # load data_epochs, times, evts for parameters
        fname = savename(d, "jld2")
        params = wload(datadir("epochs", fname))
        @unpack data_epoch, times, evts = params

        # fit model
        model = "two-stage"
        subjects = ["S"*string(i) for i in 1:nsubj];
        evts.subject = replace.(evts.subject, "S0" => "S")

        # partition epochs by subjects
        data_epoch_subjects = []
        map(Base.Iterators.partition(axes(data_epoch,3), nitem)) do cols
            push!(data_epoch_subjects, data_epoch[:, :, cols])
        end
    
        # fit model per subject 
        cond_temp = fit_unfold_model.((evts,), data_epoch_subjects, (times, ), subjects)
        condA = [row[1][1] for row in eachrow(cond_temp)]
        condB = [row[1][2] for row in eachrow(cond_temp)]
    
        # ttest & pvalue
        condA = hcat(condA...)
        condB = hcat(condB...)

        # extract peaks 
        window = 70:110 #QUICKFIX (window + extract peaks)
        x = maximum.(eachcol(condA[window, :]))
        y = maximum.(eachcol(condB[window, :]))

        # ttest + pvalue
        p = pvalue(OneSampleTTest(x, y))

        # logging
        time = Dates.format(now(UTC), dateformat"yyyy-mm-dd HH:MM:SS")
        @info savename(time, d; connector=" | ", equals=" = ", sort=false, digits=2)

        # add new values to dictionary params
        ks = ["pvalue"]
        vs = [p]
        foreach(((k, v), ) -> params[k] = v, zip(ks, vs))

        # saving
        sname = savename(d, "jld2")
        mkpath(datadir("analysis", model))
        wsave(datadir("analysis", model, sname), params)
    end

    """
    Compute power
    """
    function compute_power(params)
        # unpack parameter
        @unpack model, nsubj, nitem, β, σranef, σres, noisetype, noiselevel = params

        # prepare parameters for logging, loading and saving
        d = @dict nsubj nitem β σranef σres noisetype noiselevel
        map!(x->replace(string(x), string(typeof(x)) => ""), values(d))

        # create regex for result loading
        r = deepcopy(d)
        r[:seed] = "XXX" # placeholder
        rfname = replace(savename(r), "["=>"\\[", "]"=>"\\]", "("=>"\\(", ")"=>"\\)", " "=>"\\s")
        rfname = replace(rfname, "XXX"=>"([1-9][0-9]{0,2}|1000)")
        
        # load results
        res = collect_results(datadir("analysis");white_list=["seed", "nsubj", "nitem", "pvalue"], subfolders = true, rinclude=[Regex(rfname)])

        # get pvalues & compute power
        pvalues = res.pvalue
        power = length(pvalues[pvalues.<0.05]) / length(pvalues) * 100

        # logging
        time = Dates.format(now(UTC), dateformat"yyyy-mm-dd HH:MM:SS")
        @info savename(time, d; connector=" | ", equals=" = ", sort=false, digits=2)

        # add new values to dictionary params
        ks = ["power"]
        vs = [power]
        foreach(((k, v), ) -> params[k] = v, zip(ks, vs))

        # saving
        sname = savename(d, "jld2")
        mkpath(datadir("power", model))
        wsave(datadir("power", model, sname), params)

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

# Epoch data
@info "Epoching data..."
#res = pmap(epoch_data, dicts)

# Analysis
@info "Starting two-stage analysis..."
#res = pmap(analysis_2stage, dicts)

# Compute power
delete!(cfg, "seed")
cfg["model"] = ["two-stage"]
dicts = dict_list(cfg)
@info "Computing power..."
res = pmap(compute_power, dicts)