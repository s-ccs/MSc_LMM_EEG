using CairoMakie
using ColorSchemes
using DelimitedFiles
using DrWatson

# include helper functions
include("../src/helpers.jl")

# activate makie backend
CairoMakie.activate!()

# specify data directory 
srcdir = projectdir("data/power")
files = readdir(srcdir, join=true)

# filter / selected parameters 
# (adjust by your needs)
fβ = "[2.0, 0.1]"
fσranef = [
    "(:subj => [0.0 0.0; 0.0 0.0])",
    "(:subj => [0.0 0.0; 0.0 0.1])"
]
fσres = 0.0001
fnoisetype = "pink"
fnoiselevel = 1.0
fnsubj = 7
	
# plot parameters
nsubj = 3:2:50
nitem = 2:2:50

# create figure
fig = Figure(
    backgroundcolor = :white,
    resolution = (1500, 800),
    figure_padding = 20
)

# create axis for lmm
ax1 = Axis(
    aspect=1,
    fig[1, 2],
    title = "LMM",
    titlesize = 30,
    xlabel = "Number of Items",
    ylabel = "Power",
    #subtitle = subtitle,
    subtitlesize = 25.0f0,
    subtitlegap = 10,
    titlegap = 30,
    xautolimitmargin = (0.0, 0.0),
    xminorticksvisible = true,
    xminorticks = IntervalsBetween(5),
    xticks=0:5:maximum(nitem),
    xlabelpadding = 20,
    xlabelfont="TeX Gyre Heros Makie Bold",
    xlabelsize=25,

    yautolimitmargin = (0.0, 0.0),
    yminorticksvisible = true,
    yminorticks = IntervalsBetween(5),
    yticks=0:10:maximum(100),
    ylabelpadding = 20,
    ylabelfont="TeX Gyre Heros Makie Bold",
    ylabelsize=25
)

xlims!(0,maximum(nitem))
ylims!(0,100)

# create axis for twostage
ax2 = Axis(
    aspect=1,
    fig[1, 1],
    title = "Two-Stage",
    titlesize = 30,
    xlabel = "Number of Items",
    ylabel = "Power",
    #subtitle = subtitle,
    subtitlesize = 25.0f0,
    subtitlegap = 10,
    titlegap = 30,
    xautolimitmargin = (0.0, 0.0),
    xminorticksvisible = true,
    xminorticks = IntervalsBetween(5),
    xticks=0:5:maximum(nitem),
    xlabelpadding = 20,
    xlabelfont="TeX Gyre Heros Makie Bold",
    xlabelsize=25,

    yautolimitmargin = (0.0, 0.0),
    yminorticksvisible = true,
    yminorticks = IntervalsBetween(5),
    yticks=0:10:maximum(100),
    ylabelpadding = 20,
    ylabelfont="TeX Gyre Heros Makie Bold",
    ylabelsize=25
)

xlims!(0,maximum(nitem))
ylims!(0,100)


for fmodel in ["lmmperm", "twostage"]
    for file in files
        # skip files not ending with .csv
        !endswith(file, ".csv") && continue

        # parse filename and unpack to variables
        p = parse_savename(file)
        params_str = p[2]
        @unpack β, σranef, σres, noisetype, noiselevel, model = params_str

        # filter 
        fβ != nothing && fβ != β  && continue
        fσranef  != nothing && σranef ∉ fσranef  && continue
        fσres != nothing && fσres != σres  && continue
        fnoisetype != nothing && fnoisetype != noisetype  && continue
        fnoiselevel != nothing && fnoiselevel != noiselevel  && continue
        fmodel != nothing && fmodel != model  && continue

        # load power matrix
        P = readdlm(file, ',', Float64, '\n')

        # select respective axis
        ax = (fmodel == "lmmperm" ? ax1 : ax2)

        # plot lines
        lines!(ax, collect(nitem), P[indexin(fnsubj, nsubj)[1],:], label=σranef)
        @info β, σranef, σres, noisetype, noiselevel, model
    end
end

# some renaming
β, σranef, σres, noisetype, noiselevel, nsubj = fβ, fσranef, fσres, fnoisetype, fnoiselevel, fnsubj 

# create subtitle
s1 = savename(@dict nsubj β σres; connector="   |   ", equals=" = ", sort=true, digits=5)
s2 = savename(@dict noisetype noiselevel; connector="   |   ", equals=" = ", sort=true, digits=5)
subtitle = s1 * " \n " * s2

# add super title and subtitle
fig[0, :] = Label(fig, subtitle, fontsize=30, font="TeX Gyre Heros Makie")
fig[-1, :] = Label(fig, "Power (Two-Stage vs. LMM)", fontsize=40, font="TeX Gyre Heros Makie Bold", padding=(0,0,0,0))

# create legend
Legend(fig[1,3], ax2, "σranef")

# create path
path = mkpath(projectdir("plots"))

# prepare parameters for filename
d = @dict nsubj β σres noisetype noiselevel
sname = replace(savename(d, ".png"), "f"=>"")
fname = replace(sname, 
    "β" => "beta",
    "σranef" => "ranef",
    "σres" => "res",
    "model=lmmperm_"=>""
)

# save figure
save(path * "/power-twostagevslmm-"*fname, fig)