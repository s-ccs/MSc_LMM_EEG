using CairoMakie
using ColorSchemes
using DelimitedFiles
using DrWatson

# include helper functions
include("../src/helpers.jl")

# activate makie backend
CairoMakie.activate!()

# specify data directory 
srcdir = projectdir("data/sanitycheck")
files = readdir(srcdir, join=true)

# iterate over all files
for file in files
    # skip file if not a csv
    !endswith(file, ".csv") && continue

    # parse filename
    p = parse_savename(file)
    params_str = p[2]

    @unpack β, σranef, σres, noisetype, noiselevel, model = params_str
    nsubj = parse_range(params_str["nsubjs"])
    nitem = parse_range(params_str["nitems"])

    # create the xaxis range from nsubj
    xs = LinRange((minimum(nsubj)), maximum(nsubj), length(nsubj))
    xs = [0.0; collect(xs)]

    # create the xaxis range from nitem
    ys = LinRange((minimum(nitem)), maximum(nitem), length(nitem))
    ys = [0.0; collect(ys)]

    # collect colors for the 10 power contour lines
    c = collect(reverse(cgrad(:Blues, 10)))[1:10];
    c = [(ci,1) for ci in c]
    
    # create figure
    f = Figure(
        backgroundcolor = :white,
        resolution = (1100, 1100),
        figure_padding = 20
    )
    
    # create axis
    ax = Axis(
        f[1, 1],
        aspect = 1,
        xlabel = "Number of Items",
        ylabel = "Probability",
        subtitlegap = 10,
        titlegap = 30,
        xautolimitmargin = (0.0, 0.0),
        xminorticksvisible = true,
        xminorticks = IntervalsBetween(5),
        xticks=0:5:maximum(nsubj),
        xlabelpadding = 20,
        xlabelfont="TeX Gyre Heros Makie Bold",
        xlabelsize=30,

        yautolimitmargin = (0.0, 0.0),
        yminorticksvisible = true,
        yminorticks = IntervalsBetween(5),
        yticks=0:5:maximum(nitem),
        ylabelpadding = 20,
        ylabelfont="TeX Gyre Heros Makie Bold",
        ylabelsize=30,
    )
    
    # load the power matrix
    P = readdlm(file, ',', Float64, '\n')

    # init empty matrix, pad with one row and column of zeros, add power values
    m = zeros(length(nsubj)+1,  length(nitem)+1)
    m[2:end, 2:end] = P

    # create labels
    labels = [string(i) for i in nsubj][begin:1:end]
	
    # plot series
    series!(nitem, P[begin:1:end,:], color=collect(cgrad(:thermal, rev = true, categorical = true, 30)), alpha=0.5, labels=labels)

    # limit x- and y-axis
    xlims!(0,maximum(nitem))
	ylims!(0,20)

    # create and add super title
    f[-1, :] = Label(f, "Type 1 Error", fontsize=30, font="TeX Gyre Heros Makie Bold", padding=(0,0,0,0))

    # create subtitle containg parameters
    s1 = savename(@dict β σranef σres; connector="   |   ", equals=" = ", sort=true, digits=5)
    s2 = savename(@dict model noisetype noiselevel; connector="   |   ", equals=" = ", sort=true, digits=5)
    subtitle = s1 * " \n " * s2

    # add subtitle
    f[0, :] = Label(f, subtitle, fontsize=25, font="TeX Gyre Heros Makie")

    # create legend
    Legend(f[1,2], ax, "Number of\n subjects", nbanks = 2)

    # create path
    path = mkpath(projectdir("plots"))

    # adjust the filename
    fname = replace(file, 
        ".csv"=>".png", 
        p[1]=>"",
        "β" => "beta",
        "σranef" => "ranef",
        "σres" => "res",
    )

    # save plots
    save(path * "/type1-"*fname, f)
end