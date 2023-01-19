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
        resolution = (1000, 1000),
        figure_padding = 20
    )
    
    # create axis
    ax = Axis(
        f[1, 1],
        aspect = 1,
        #title = "Power Contour",
        xlabel = "Number of Subjects",
        ylabel = "Number of Items",
        #subtitle = subtitle,
        #subtitlesize = 25.0f0,
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

    # contour plot
    contour!(ax, xs, ys, m,
        levels=[10,20,30,40,50,60,70,80,90,95],
        color=c,
        linewidth = 2,
        alpha=1,
        transparency = true,
    )

    # create second color set with all colors at aplha=0, except for the 8th contour line (80 percent level)
    c2 = repeat([(c[8], 0)], 10)
    c2[8] = (c[8], 1)

    # overlay the 8th line with a bigger linewidth
    contour!(ax, xs, ys, m,
        levels=[10,20,30,40,50,60,70,80,90,95],
        color=c2,
        linewidth = 8,
        alpha=1,
        transparency = true,
    )

    # create and add super title
    f[-1, :] = Label(f, "Power Contour", fontsize=30, font="TeX Gyre Heros Makie Bold", padding=(0,0,0,0))

    # create subtitle containg parameters
    s1 = savename(@dict β σranef σres; connector="   |   ", equals=" = ", sort=true, digits=5)
    s2 = savename(@dict model noisetype noiselevel; connector="   |   ", equals=" = ", sort=true, digits=5)
    subtitle = s1 * " \n " * s2

    # add subtitle
    f[0, :] = Label(f, subtitle, fontsize=25, font="TeX Gyre Heros Makie")

    # helper code for legend
    g = Figure(resolution = (800, 600))
    Axis(g[1,1])
    l = []
    for i in 1:10
        lin = lines!(g[1,1], 1:10, rand(10), color=c[i][1], linewidth=(i==8 ? 5 : 2))
        push!(l, lin)
    end

    # create legend
    Legend(f[1, 2], l, " " .* string.((1:length(l)).*10).* " %", "Power")

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
    save(path * "/single-"*fname, f)
end