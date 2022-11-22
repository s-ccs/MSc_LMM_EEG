using ArgParse
using TOML
using DSP
using MixedModels: @formula, EffectsCoding
using MixedModelsSim: create_re
using UnfoldSim

function args_parse()
    s = ArgParseSettings()
    @add_arg_table s begin
        "filename"
            help = "config file with parameters"
            arg_type = String
            required = true
    end
    return parse_args(s)
end

function config(filename)
    c = TOML.parsefile(filename)

    config = Dict(
        # variable parameters
        "seed" => isa(c["seed"], Dict) ? parse_range(c["seed"]) : c["seed"],
        "nsubj" => isa(c["nsubj"], Dict) ? parse_range(c["nsubj"]) : c["nsubj"],
        "nitem" => isa(c["nitem"], Dict) ? parse_range(c["nitem"]) : c["nitem"],
        "β" => c["beta"],
        "σranef" => [Dict([(Symbol(k), create_re(v...)) for (k,v) in d]) for d in c["sigmaranef"]],
        "σres" => c["sigmares"],
        "noisetype" => parse_noisetype(c["noisetype"]),
        "noiselevel" => c["noiselevel"],
	"models" => c["models"],

        # fixed parameters
        "subj_btwn" => nothing,
        "item_btwn" => Dict("stimType" => ["A", "B"]),
        "both_win" => nothing,
        "basis" => [padarray(hanning(50), (-50, 50), 0)],
        "fixationlen" => 305,
        "formula" => @formula(dv ~ 1 + stimType + (1 + stimType | subj)),
        "contrasts" => Dict(:stimType => EffectsCoding()),
    )
    return config

end

function parse_range(dict)
    return dict["start"]:dict["step"]:dict["end"]
end

function parse_noisetype(noisetype)
    if noisetype === "white"
        n = WhiteNoise()
    elseif noisetype === "red"
        n = RedNoise()
    elseif noisetype === "pink"
        n = PinkNoise()
    else
        error("unkown noisetype")
    end
    return n
end

# Config
# args = Dict(
#     # variable parameters
#     "seed" => collect(1:1000),
#     "nsubj" => [2,4,6],
#     "nitem" => collect(2:2:20),
#     "β" => [[2. ,0.25]],
#     "σranef" => Dict(:subj => create_re(0.0, 0.0), :item=>create_re(0.0)),
#     "σres" => 0.0001,
#     "noisetype" => WhiteNoise(),
#     "noiselevel" => 2,
#     # fixed parameters
#     "subj_btwn" => nothing,
# 	"item_btwn" => Dict("stimType" => ["A", "B"]),
# 	"both_win" => nothing,
#     "basis" => [padarray(hanning(50), (-50, 50), 0)],
#     "formula" => @formula(dv ~ 1 + stimType + (1 + stimType | subj) + (1 | item)),
#     "contrasts" => Dict(:stimType => EffectsCoding()),
# )
