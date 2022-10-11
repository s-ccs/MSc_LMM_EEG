using DrWatson
@quickactivate "MSc_LMM_EEG" # <- project name

using DSP
using Random
using MixedModels: EffectsCoding
using Unfold
using UnfoldSim
using Distributed

# GENERAL OVERVIEW
 # (Repeat n times with different seeds)
    # Execute single simulation with parameters
    # 1) eeg, onsets = simulate()
    # 2) data, evts = convert(eeg, onsets, design)
    # 3) epochs, times = Unfold.epoch()
    # 4) Fit Model (1-Average / 2-LMM / 3-MEMA)
    # 5) P-value (Option A or B)
    # 5.A) Extract peaks, t-test
    # 5.B) Cluster permutation test
    # 6) Save pvalue / data


function simulate_data(params)

    # unpack parameter
    @unpack seed, nsubj, nitem, subj_btwn, item_btwn, both_win, β, σranef, σres, basis, formula, contrasts, noisetype, noiselevel = params

    # create random number generator from seed
    rng = MersenneTwister(seed)

    # init
    fixationlen = 305 # still fixed => part of parameters
    design = ExperimentDesign(nsubj, nitem, subj_btwn, item_btwn, both_win)
    component = Component(basis, formula, contrasts, β, σranef, σres)
    simulation = Simulation(design, [component], length(basis), fixationlen, noisetype, noiselevel)

    # simulate
    eeg, onsets = UnfoldSim.simulate(deepcopy(rng), simulation)
    data, evts = UnfoldSim.convert(eeg, onsets, design)

    # add data to params
    params["data"] = data
    params["evts"] = evts

    # prepare params
    _σranef = join([(σranef...)...], "-")
    _β = join([(β...)...], "-")
    _formula = filter(x -> !isspace(x), string(formula))
    _noisetype = replace(string(noisetype), "UnfoldSim."=>"", "()" => "")

    # Save data
    sname = savename(( @dict seed noisetype=_noisetype noiselevel formula=_formula σres σranef=_σranef β=_β nitem nsubj), "jld2")
    mkpath(datadir("simulation"))
    wsave(datadir("simulation", sname), params)

    return true
end

# TODO create central config file for all scripts?
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
    "noisetype" => WhiteNoise(),
    "noiselevel" => 1
)

# Running the script
dicts = dict_list(args)
pmap(simulate_data, dicts)