#!/usr/bin/env julia

using Distributed, SlurmClusterManager

addprocs(SlurmManager(), exeflags="--project=.")

@everywhere using UnfoldSim: WhiteNoise
@everywhere using DelimitedFiles
@everywhere using DataFrames
@everywhere using DrWatson
@everywhere @quickactivate "MSc_LMM_EEG"

@everywhere begin
    function test(res, model)
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
        
        d = copy(first(select(res, ["β", "σranef", "σres", "noisetype", "noiselevel"])))
        d = Dict(pairs(d))
        d[:σranef] = [last(first(d[:σranef]))[1,1], last(first(d[:σranef]))[2,2]]
        map!(x->replace(string(x), string(typeof(x)) => ""), values(d))

        mkpath(datadir("plots", model))
        fname = savename(d, "csv"; connector="_", equals="=", sort=true, digits=5)

        writedlm(datadir("plots", model, fname),  m, ',')
    end
end


for model in ["twostage", "lmm"]
    res = collect_results(datadir("power", model))
    gdf = groupby(res, [:β, :σranef, :σres, :noiselevel, :noisetype])
    pmap(x->test(x, model), collect(gdf))
end
