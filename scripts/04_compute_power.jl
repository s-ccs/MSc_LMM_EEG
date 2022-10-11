using DrWatson
@quickactivate "MSc_LMM_EEG" # <- project name

using DSP
using Random
using MixedModels: EffectsCoding
using Unfold
using UnfoldSim
using Distributed


function compute_power(params)

    # unpack parameter
    @unpack nsubj, nitem, subj_btwn, item_btwn, both_win, β, σranef, σres, basis, formula, contrasts, noiselevel = params

    # prepare params
    _σranef = join([(σranef...)...], "-")
    _β = join([(β...)...], "-")
    _formula = filter(x -> !isspace(x), string(formula))

    # load results
    res = collect_results!(datadir("analysis");subfolders = true)

    # filter by params # TODO extend to all args
    filt = filter(row -> row.nitem == nitem && row.nsubj == nsubj && row.β == β && row.σranef == σranef && row.σres == σres && row.noiselevel == noiselevel, res)

    # pvalues 
    pvalues = filt.pvalue

    # power
    power = length(pvalues[pvalues.<0.05]) / length(pvalues) * 100

    # add power to params
    params["power"] = power

    # Save data
    model = "two-stage"
    sname = savename(( @dict noiselevel formula=_formula σres σranef=_σranef β=_β nitem nsubj), "jld2")
    mkpath(datadir("power", model))
    wsave(datadir("power", model, sname), params)

    return true
end


# Config
args = Dict(
    #"seed" => collect(1:1000),
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
pmap(compute_power, dicts)