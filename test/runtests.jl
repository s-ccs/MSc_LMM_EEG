using UnfoldSimulations
using Random
using Plots

n_subj = 4
n_item = 4
n_trial = 1

subj_btwn = nothing
item_btwn = Dict("stimType" => ["I", "II"])
both_win = nothing

evt_seq = nothing
evt_onsets = [[100];[200];[300];[400];]

expdesign = ExperimentDesign(n_subj, n_item, n_trial, subj_btwn, item_btwn, both_win, evt_seq, evt_onsets)
generate!(expdesign)

basisfunction = Hanning()

noise = WhiteNoise()

epoch_len = 100
sig_len = 600

ufs = UnfoldSim(expdesign, basisfunction, noise, epoch_len, sig_len)

f = @formula dv~1+stimType+(1+stimType|subj)+(1|item)
re = [[2.0,2.0],[1.0]]
β = [10.0, 20.0]
rng = MersenneTwister(1)
 
data = simulate(ufs, f, re, β, rng)

plot(data')
