using DrWatson
@quickactivate "MSc_LMM_EEG" # <- project name

using DSP
using Plots
gr()
using Random
using MixedModels: EffectsCoding
using Unfold
using UnfoldSim
using Distributed


function epoch_data(params)

    # unpack parameter
    @unpack seed, nsubj, nitem, subj_btwn, item_btwn, both_win, β, σranef, σres, basis, formula, contrasts, noisetype, noiselevel= params

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

    # epoch data
    τ = (-0.1, 1.2) # TODO: needs to be parameter or in a config
    sfreq = 256 # TODO: needs to be parameter or in config
    data_epoch, times = Unfold.epoch(data=data, tbl=evts, τ=τ, sfreq=sfreq)

    # add conditons to dataframe
    params["data_epoch"] = data_epoch
    params["times"] = times

    # Save data
    prefix = "epochs_"
    sname = savename(prefix, ( @dict seed noisetype=_noisetype noiselevel formula=_formula σres σranef=_σranef β=_β nitem nsubj), "jld2")
    mkpath(datadir("epochs"))
    wsave(datadir("epochs", sname), params)

    return true
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
pmap(epoch_data, dicts)