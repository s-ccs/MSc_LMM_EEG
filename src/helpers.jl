using TOML
using DSP
using MixedModels: @formula, EffectsCoding
using MixedModelsSim: create_re
using UnfoldSim


"""
Function to instantiate the configuration from a TOML-file
"""
function config(filename)
    # load and parse toml file
    c = TOML.parsefile(filename)

    # create config dictionary
    config = Dict(
        # variable parameters for the experiments
        "seed" => isa(c["seed"], Dict) ? parse_range(c["seed"]) : c["seed"],
        "nsubj" => isa(c["nsubj"], Dict) ? parse_range(c["nsubj"]) : c["nsubj"],
        "nitem" => isa(c["nitem"], Dict) ? parse_range(c["nitem"]) : c["nitem"],
        "β" => c["beta"],
        "σranef" => [Dict([(Symbol(k), create_re(v...)) for (k,v) in d]) for d in c["sigmaranef"]],
        "σres" => c["sigmares"],
        "noisetype" => parse_noisetype(c["noisetype"]),
        "noiselevel" => c["noiselevel"],
	    "models" => c["models"],

        # fixed parameters for the experiments
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


"""
Helper function to parse range from dict
"""
function parse_range(dict)
    return dict["start"]:dict["step"]:dict["end"]
end


"""
Helper function to parse range from string
"""
function parse_range(range_str)
	split_str = (parse.(Int, split(range_str, ":"))...,)
	return (length(split_str) == 2) ? (split_str[1]:split_str[2]) : (split_str[1]:split_str[2]:split_str[3])
end


"""
Helper function to parse noisetype from string
"""
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