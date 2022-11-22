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
    Create plot for given P and parameters
    """
    function plot(P, nsubj, nitem, params, model)
        theme = Theme(fontsize = 30)
        set_theme!(theme)

        dxs = Int(minimum(nsubj) / step(nsubj))
        dys = Int(minimum(nitem) / step(nitem))
        m = zeros(length(nsubj)+dxs,  length(nitem)+dys)

        m[dxs+1:end, dys+1:end] = P

        # construct subtitle
        @unpack β, σranef, σres, noisetype, noiselevel = params
        s1 = savename(@dict β σranef σres; connector="   |   ", equals=" = ", sort=true, digits=5)
        s2 = savename(@dict noisetype noiselevel model; connector="   |   ", equals=" = ", sort=true, digits=5)
        subtitle = s1 * " \n " * s2

        f = Figure(
            backgroundcolor = :white,
            resolution = (1000, 1000),
            figure_padding = 20
        )
        
        Axis(
            f[1, 1],
            title = "Power Contour",
            xlabel = "Number of Subjects",
            ylabel = "Number of Items",
            subtitle = subtitle,
            subtitlesize = 25.0f0,
            subtitlegap = 10,
            titlegap = 30,
            xautolimitmargin = (0.0, 0.0),
            xminorticksvisible = true,
            xminorticks = IntervalsBetween(5),
            xticks=0:5:maximum(nsubj),
            xlabelpadding = 20,
            xlabelfont="TeX Gyre Heros Makie Bold",

            yautolimitmargin = (0.0, 0.0),
            yminorticksvisible = true,
            yminorticks = IntervalsBetween(5),
            yticks=0:5:maximum(nitem),
            ylabelpadding = 20,
            ylabelfont="TeX Gyre Heros Makie Bold"
        )

        c = collect(reverse(cgrad(:Blues, 10)))[1:10];
        c = [(ci,1) for ci in c]

        # helper code for legend
        g = Figure(resolution = (800, 600))
        Axis(g[1,1])
        l = []
        for i in 1:10
        lin = lines!(g[1,1], 1:10, rand(10), color=c[i][1], linewidth=(i==8 ? 5 : 2))
        push!(l, lin)
        end

        xs = LinRange(0, maximum(nsubj), length(nsubj) + dxs)
            ys = LinRange(0, maximum(nitem), length(nitem) + dys)
        zs = m

        contour!(f[1,1], xs, ys, zs, 
            levels=[10,20,30,40,50,60,70,80,90,99],
            color=c,
            linewidth = 2,
            alpha=1,
            transparency = true,
        )

        c2 = repeat([(c[8], 0)], 10)
        c2[8] = (c[8], 1)
        
        contour!(f[1,1], xs, ys, zs, 
            levels=[10,20,30,40,50,60,70,80,90,99],
            color=c2,
            linewidth = 8,
            alpha=1,
            transparency = true,
        )

        xs = LinRange(0, maximum(nsubj), length(nsubj) + dxs)
        ys = LinRange(0, maximum(nitem), length(nitem) + dys)
    
        Legend(f[1, 2], l, " " .* string.((1:length(l)).*10).* " %", "Power")

        return f
    end 

    """
    Compute power for given array of pvalues (Significance level alpha = 0.05)
    """
    function power(pvalues)
        return length(pvalues[pvalues.<0.05]) / length(pvalues) * 100
    end

    """
    Compute the pvalues for given data and model
    """
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
	    fm1 = MixedModel(fm, evts)
	    fm1.optsum.maxtime = 1
	    refit!(fm1, progress=false)

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
	p = @time "$(myid()):$(gethostname()):  Computing... $nsubj, $nitem, $model" power(pvalue.(sim.(nsubj, nitem, seed, (params,)), model))
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
            
            # compute power for specific combination
	    P = @time "Create power matrix: " pmap(((nsubj, nitem),)->run_iteration(nsubj, nitem, seed, params, model), reverse([Iterators.product(nsubjs, nitems)...]))
	    P = reshape(P, (length(nsubjs), length(nitems)))

            # prepare parameters for logging, loading and saving
            @unpack β, σranef, σres, noisetype, noiselevel = params
            d = @dict nsubjs nitems model β σranef σres noisetype noiselevel
            map!(x->replace(string(x), string(typeof(x)) => ""), values(d))

            # create plot
            f = plot(P, nsubjs, nitems, params, model)

            # save P contour plot to png 
            mkpath(datadir("plots"))
            fname = savename(d, "png")
            save(datadir("plots", fname), f)

            # save to csv
            sname = savename(d, "csv")
            mkpath(datadir("power"))
            @time "Saving:" writedlm(datadir("power", sname),  P, ',')
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
cfg = config(ARGS[1])

# Split config into list of parameter combinations
dicts = dict_list(cfg)
n_dicts = dict_list_count(cfg)

# Simulate data & compute pvalues
@info "Creating power matrices... $(n_dicts)"
flush(stderr)
#@time "All:" pmap(run, dicts)

@time "All:" for p in dicts
    run(p)
end
