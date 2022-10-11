using DrWatson
@quickactivate "MSc_LMM_EEG" # <- project name

using DSP
using Random
using MixedModels: EffectsCoding
using Unfold
using UnfoldSim
using Distributed


function analyse_data(params)

    # unpack parameter
    @unpack seed, nsubj, nitem, subj_btwn, item_btwn, both_win, β, σranef, σres, basis, formula, contrasts, noisetype, noiselevel = params

    # prepare params
    _σranef = join([(σranef...)...], "-")
    _β = join([(β...)...], "-")
    _formula = filter(x -> !isspace(x), string(formula))
    _noisetype = replace(string(noisetype), "UnfoldSim."=>"", "()" => "")


    # file name
    fname = savename(( @dict seed noisetype=_noisetype noiselevel formula=_formula σres σranef=_σranef β=_β nitem nsubj), "jld2")

    # load data, evts
    params = wload(datadir("simulation", fname))
    data = params["data"]
    evts = params["evts"]

    # fit model
    model = "two-stage"
    subjects = ["S"*string(i) for i in 1:nsubj];
    condA = fit_two_stage_model.((evts,), (data,), subjects, ("condA", ))
	condB = fit_two_stage_model.((evts,), (data,), subjects, ("condB", ))

    # ttest & pvalue
    condA = hcat(condA...)
    condB = hcat(condB...)

    # add conditons to dataframe
    params["condA"] = condA
    params["condB"] = condB

    # TODO: 
    # extract peaks 
    x = maximum.(eachcol(condA))
    y = maximum.(eachcol(condB))

    # TODO:
    # ttest + pvalues
    p = pvalue(OneSampleTTest(x, y))
    params["pvalue"] = p

    # Save data
    sname = savename(( @dict seed noisetype=_noisetype noiselevel formula=_formula σres σranef=_σranef β=_β nitem nsubj), "jld2")
    mkpath(datadir("analysis", model))
    wsave(datadir("analysis", model, sname), params)

    return true
end


"""
Helper function to fit unfold model
"""
function fit_two_stage_model(evts, data, subj, cond)
    # TODO
	# basisfunction via FIR basis 
	basisfunction = firbasis(τ=(-0.1,1.2), sfreq=256, name="stimulus")
	
	# formula in wilikinson notation
	f  = @formula 0~0+condA+condB;

	# map basidfunction & formula into a dict
	bfDict = Dict(Any=>(f, basisfunction));

	# filter subjects events out
	subj_evts = filter(row -> row.subject == subj, evts)

	# fit model
	m = fit(UnfoldModel, bfDict, subj_evts, data)

	# create result dataframe
	results = coeftable(m)

    # filter by condition
	cond_unfold = filter(row->row.coefname==cond, results).estimate

	return cond_unfold
end


# Config
args = Dict(
    "seed" => collect(1:1000),
    "subj_btwn" => nothing,
	"item_btwn" => Dict("stimType" => ["A", "B"]),
	"both_win" => nothing,
    "nsubj" => [2],
    "nitem" => [2,4,6,8,10,12,14,16,18,20],
    "β" => [[2. ,0.5]],
    "σranef" => [[[0.0, 0.0], [0]]],
    "σres" => 0.0001,
    "basis" => [padarray(hanning(50), (-50, 50), 0)],
    "formula" => @formula(dv ~ 1 + stimType + (1 + stimType | subj) + (1 | item)),
    "contrasts" => Dict(:stimType => EffectsCoding()),
    "noiselevel" => 1
)


# Running the script
dicts = dict_list(args)
pmap(analyse_data, dicts)