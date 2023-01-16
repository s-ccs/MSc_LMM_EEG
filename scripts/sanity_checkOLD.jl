#!/usr/bin/env julia

using Distributed, SlurmClusterManager

addprocs(SlurmManager(), exeflags="--project=.")
#addprocs(4, exeflags="--project=.")


@everywhere using DrWatson
@everywhere using Dates
@everywhere @quickactivate "MSc_LMM_EEG"
@everywhere using MixedModels: @formula, fit, MixedModel, fixefnames
@everywhere using CairoMakie
@everywhere using DataFrames

@everywhere begin
    if (length(ARGS) > 1)
        datadir(args...) = projectdir(ARGS[2], args...)
    end
end

@everywhere begin
    using Random
    using Unfold
    using UnfoldSim
    using StableRNGs
    using Statistics
    using HypothesisTests
    using MixedModelsPermutations
    

    """
    Simulate data and analyse data based on parameterization
    """
    function compute_pvalues(params; twostage=true, lmm=true, quicklmm=true, timeexpanded=false)
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

        # epoch data
        τ = (-0.1, 1.2) #QUICKFIX
        sfreq = 256 #QUICKFIX
        data_epoch, times = Unfold.epoch(data=data, tbl=evts, τ=τ, sfreq=sfreq)

        # analysis
        window = 89:89
        avg = mean(data_epoch[:, window, :], dims=2)
        evts.dv = [avg...]

        # two stage
        if twostage && !timeexpanded
            gd = groupby(evts, [:subject, :cond])
            mv = combine(gd, [:dv] .=> mean)
            x = filter(:cond => ==("A"), mv).dv_mean
            y = filter(:cond => ==("B"), mv).dv_mean
            pvalue_twostage = pvalue(OneSampleTTest(x, y))

            # add to params
            params["pvalue_twostage"] = pvalue_twostage
        end

        # analysis (lmm)
        if lmm && !timeexpanded
            fm = @formula(dv ~ 1 + cond + (1 + cond | subject))
            fm1 = fit(MixedModel, fm, evts, progress=false)

	    if quicklmm
	        pvalue_lmm = fm1.pvalues[indexin(["cond: B"], fixefnames(fm1))[1]]
	    elseif !quicklmm
                H0 = coef(fm1) # H0 (slope of stimType=0 ?)
                H0[2] = 0
                pvalue_lmm = try
                    perm = permutation(StableRNG(42), 1000, fm1; β=H0, hide_progress=true)
                    pvalues = permutationtest(perm, fm1)
                    getproperty(pvalues, Symbol("cond: B"))
                catch e
                    @warn e seed nsubj nitem β σranef σres noisetype noiselevel
                    missing
                end
	        end

            # add to params
            params["pvalue_lmm"] = pvalue_lmm
        end

        # only select variable params
        filter!(((k,v),) -> k in ["seed", "nsubj", "nitem", "β",  "σranef", "σres", "noisetype", "noiselevel", "pvalue_twostage", "pvalue_lmm"], params)

        # prepare parameters for logging, loading and saving
        d = @dict seed nsubj nitem β σranef σres noisetype noiselevel
        map!(x->replace(string(x), string(typeof(x)) => ""), values(d))

	    d1 = @dict nsubj nitem β σranef σres noisetype noiselevel
        map!(x->replace(string(x), string(typeof(x)) => ""), values(d1))

        # saving
        sdir = "pvalues"
        sname = savename(d, "jld2")
	    subdir = savename(d1)
        mkpath(datadir(sdir, subdir))
        wsave(datadir(sdir, subdir, sname), params)

        # logging
        d = @dict seed nsubj nitem β σranef σres noisetype noiselevel
        map!(x->replace(string(x), string(typeof(x)) => ""), values(d))
        time = Dates.format(now(UTC), dateformat"yyyy-mm-dd HH:MM:SS")
        info = "$(myid()):$(gethostname()) : "
        @info savename(info*time, d; connector=" | ", equals=" = ", sort=false, digits=2)

        return true
    end


    """
    Compute power
    """
    function compute_power(params; twostage=true, lmm=false)

        # unpack parameter
        @unpack nsubj, nitem, β, σranef, σres, noisetype, noiselevel = params

        # prepare parameters for logging, loading and saving
        d = @dict nsubj nitem β σranef σres noisetype noiselevel
        map!(x->replace(string(x), string(typeof(x)) => ""), values(d))

	    d1 = @dict nsubj nitem β σranef σres noisetype noiselevel
        map!(x->replace(string(x), string(typeof(x)) => ""), values(d1))
        subdir = savename(d1)

        # create regex for result loading
        #r = deepcopy(d)
        #r[:seed] = "XXX" # placeholder
        #rfname = replace(savename(r), "["=>"\\[", "]"=>"\\]", "("=>"\\(", ")"=>"\\)", " "=>"\\s")
        #rfname = replace(rfname, "XXX"=>"([1-9][0-9]{0,2}|1000)")

        # load results
	    # res = collect_results(datadir("pvalues", subdir); black_list=["noiselevel", "noisetype", "nitem", "nsubj", "seed", "β", "σres", "σranef"], subfolders = false, rinclude=[Regex(rfname)], verbose=false)
	    res = collect_results(datadir("pvalues", subdir);subfolders = false)
															 
        # iterate over MixedModels
        for pvalue_model in intersect(["pvalue_twostage", "pvalue_lmm"], names(res))
            # get pvalues & compute power
            pvalues = res[!, pvalue_model]
            power = length(pvalues[pvalues.<0.05]) / length(pvalues) * 100

            # add to params
            params[replace(pvalue_model, "pvalue"=>"power")] = power
	    
	        # filter params
            filter!(((k,v),) -> k in ["seed", "nsubj", "nitem", "β",  "σranef", "σres", "noisetype", "noiselevel", "power_twostage", "power_lmm"], params)

            # saving
            sname = savename(d, "jld2")
            model = replace(pvalue_model, "pvalue_"=>"")
            mkpath(datadir("sanitycheck", model))
            wsave(datadir("sanitycheck", model, sname), params)
        end

        # logging
        time = Dates.format(now(UTC), dateformat"yyyy-mm-dd HH:MM:SS")
        info = "$(myid()):$(gethostname()) : "
        @info savename(info*time, d; connector=" | ", equals=" = ", sort=false, digits=2)

        return true
    end

    
    """
    Plotting
    """
    function plot(res, model)
		theme = Theme(fontsize = 30)
		set_theme!(theme)

		subjs = sort([Set(res.nsubj)...])
		subjs_step = subjs[2] - subjs[1]
		nsubj = minimum(subjs):subjs_step:maximum(subjs)

		items = sort([Set(res.nitem)...])
		items_step = items[2] - items[1]
		nitem = minimum(items):items_step:maximum(items)

		dxs = Int(minimum(nsubj) / step(nsubj))
		dys = Int(minimum(nitem) / step(nitem))
		m = zeros(length(nsubj)+dxs,  length(nitem)+dys)

		for i in 0:maximum(nsubj)
			for j in 0:step(nitem):maximum(nitem)
				r = filter(n -> n.nsubj==i && n.nitem ==j, res)[!, "power_"*model]
				m[i+1,Int(j/2)+1] = (isempty(r) ? 0.0 : Base.convert.(Float64, r)[1])
			end
		end

		# construct subtitle
		d = copy(first(select(res, ["β", "σranef", "σres", "noisetype", "noiselevel"])))
		d = Dict(pairs(d))
		d[:σranef] = [last(first(d[:σranef]))[1,1], last(first(d[:σranef]))[2,2]]
		map!(x->replace(string(x), string(typeof(x)) => ""), values(d))
		@unpack β, σranef, σres, noisetype, noiselevel = d
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
		    xticks=0:5:maximum(subjs),
		    xlabelpadding = 20,
		    xlabelfont="TeX Gyre Heros Makie Bold",

		    yautolimitmargin = (0.0, 0.0),
		    yminorticksvisible = true,
		    yminorticks = IntervalsBetween(5),
		    yticks=0:5:maximum(items),
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

		mkpath(datadir("plots", model))
		fname = savename(d, "png"; connector="_", equals="=", sort=true, digits=5)

		save(datadir("plots", model, fname), f)
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

# parse toml configs
#filenames  = let expr = Meta.parse(ARGS[1])
#    @assert expr.head == :vect
#    string.(expr.args)
#end

for filename in readdir(ARGS[1];join=true)
        # Skip hidden files
	startswith(filename, ".") && continue

	@info "$(filename)"
	# Create config
	# args = args_parse()
	cfg = config(filename)

	# Split config into list of parameter combinations
	dicts = dict_list(cfg)
	n_dicts = dict_list_count(cfg)

	# Simulate data & compute pvalues
	@info "Simulating data... $(n_dicts)"
	flush(stderr)
	#res = pmap(compute_pvalues, dicts)

	# Prpare params for power computation
	delete!(cfg, "seed")
	dicts = dict_list(cfg)
	n_dicts = dict_list_count(cfg)

	# Compute power
	@info "Compute power... $(n_dicts)"
	flush(stderr)
	res = pmap(compute_power, dicts)
end

#@info "Plotting..."
#flush(stderr)
# plot
#for model in ["twostage", "lmm"]
#    res = collect_results(datadir("power", model))
#    gdf = groupby(res, [:β, :σranef, :σres, :noiselevel, :noisetype])
#    pmap(x->plot(x, model), collect(gdf))
#end


# Removing workers
rmprocs(workers())

