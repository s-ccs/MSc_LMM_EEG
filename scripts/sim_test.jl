using DrWatson
@quickactivate "MSc_LMM_EEG" # <- project name

using DSP
using Plots
using Random
using MixedModels: EffectsCoding
using HypothesisTests
using Unfold
using UnfoldSim
using Distributed





function run_simulation(params)
    @unpack seed, model, nsubj, nitem, β, σranef, σres, basis, formula, contrasts = params

    rng = MersenneTwister(seed)

    # temporary fixed variables
    subj_btwn = nothing
	item_btwn = Dict("stimType" => ["A", "B"])
	both_win = nothing

    # init structs
    design = ExperimentDesign(nsubj, nitem, subj_btwn, item_btwn, both_win)
    simulation = Simulation(design, basis, formula, contrasts)

    # simulate
    eeg, onsets = UnfoldSim.simulate(rng, simulation, β, σranef, σres)
    data, evts = UnfoldSim.convert(eeg, onsets, design)

    # epoching
    τ = (-0.1, 1.2)
    sfreq = 256
    data_epoch, times = Unfold.epoch(data=data, tbl=evts, τ=τ, sfreq=sfreq)


    # fit model
    subjects = ["S"*string(i) for i in 1:nsubj];
    condA = fit_two_stage_model.((evts,), (data,), subjects, ("condA", ))
	condB = fit_two_stage_model.((evts,), (data,), subjects, ("condB", ))

    # ttest & pvalue
    condA = hcat(condA...)
    condB = hcat(condB...)

    # pl = plot([condA, condB])
    # prefix = "plot_cond"
    # png(pl, savename(prefix, ( @dict seed nitem nsubj), "png"))

    # extract peaks 
    x = maximum.(eachcol(condA))
	y = maximum.(eachcol(condB))

	p = pvalue(OneSampleTTest(x, y))
    params["pvalue"] = p

    # Save data
    sname = savename(( @dict seed nitem nsubj), "jld2")
    mkpath(datadir("results", params["model"]))
    save(datadir("results", params["model"], sname), params)
    return true
end


"""
Helper function to fit unfold model
"""
function fit_two_stage_model(evts, data, subj, cond)
	# basisfunction via FIR basis
	basisfunction = firbasis(τ=(-0.1,1.2), sfreq=256, name="stimulus")
	
	# formula in wilikinson notation
	f  = @formula 0~0+condA+condB;

	# map basidfunction & formula into a dict
	bfDict = Dict(Any=>(f, basisfunction));

	# filter subjects events out
	subj_evts = filter(row -> row.subject == subj, evts)

	# fit model
	m = fit(UnfoldModel, bfDict, subj_evts, data);

	# create result dataframe
	results = coeftable(m);

    # filter by condition
	cond_unfold = filter(row->row.coefname==cond, results).estimate

	return cond_unfold
end


args = Dict(
    "seed" => collect(1:1000),
    "model" => ["two-stage"],
    "nsubj" => [6],
    "nitem" => [10],
    "β" => [[2. ,0.0]],
    "σranef" => [[[0.0, 0.0], [0]]],
    "σres" => 0.0001,
    "basis" => [padarray(hanning(50), (-50, 50), 0)],
    "formula" => @formula(dv ~ 1 + stimType + (1 + stimType | subj) + (1 | item)),
    "contrasts" => Dict(:stimType => EffectsCoding())
)

dicts = dict_list(args)
pmap(run_simulation, dicts)