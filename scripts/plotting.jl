#!/usr/bin/env julia

using Distributed#, SlurmClusterManager
using ProgressMeter
#addprocs(SlurmManager(), exeflags="--project=test")
addprocs(30, exeflags="--project=.")

@everywhere using DrWatson
@everywhere using Dates
@everywhere @quickactivate "MSc_LMM_EEG"



datadir(args...) = projectdir("../../../data/MSc_LMM_EEG/", args...)

res = collect_results(datadir("power", "two-stage"), white_list=["power", "nsubj", "nitem"])

m = zeros(10,10)

for i in 1:10
    for j in 2:2:20
        r = filter(n -> n.nsubj==i && n.nitem ==j, res).power
        m[i,Int(j/2)] = (isempty(r) ? 0.0 : convert.(Float64, r)[1])
    end
end


let
	f = Figure(
		backgroundcolor = :transparent,
		resolution = (800, 800),
		figure_padding = 0
	)
	
	Axis(
		f[1, 1],
		title = "Power Contour",
    	xlabel = "Number of Subjects",
    	ylabel = "Number of Items",
		subtitle = "σ_btwn = 10 | σ_wthn = 1",
		subtitlegap = 2,
    	titlegap = 25,
		xautolimitmargin = (0.0, 0.0),
		xminorticksvisible = true,
		xminorticks = IntervalsBetween(2),
		xticks=1:2:10,
		xlabelpadding = 20,
		xlabelfont="TeX Gyre Heros Makie Bold",
			
		yautolimitmargin = (0.0, 0.0),
		yminorticksvisible = true,
		yminorticks = IntervalsBetween(2),
		yticks=1:2:10,
		ylabelpadding = 20,
		ylabelfont="TeX Gyre Heros Makie Bold"
	)
	
	xs = LinRange(0, 10, 11)
	ys = LinRange(0, 10, 11)
	zs = [x*y for x in xs, y in ys]

	c = collect((cgrad(:Blues, 11)))[8:end];

	# helper code for legend
	g = Figure(resolution = (800, 600))
	Axis(g[1,1])
	l = []
	for i in 1:10
		lin = lines!(g[1,1], 1:10, rand(10), color=c[i], linewidth=(i==8 ? 5 : 2))
		push!(l, lin)
	end
	
	contour!(f[1,1], xs, ys, zs, 
		levels=10,
		colormap=c,
		linewidth = 2,
		alpha=1,
		transparency = true,
	)

	c2 = repeat([(c[8], 0)], 12)
	c2[8] = (c[8], 1)
	contour!(f[1,1], xs, ys, zs, 
		levels=10,
		colormap=c2,
		linewidth = 5,
		alpha=1,
		transparency = true,
	)

	

	Legend(f[1, 2], l, " " .* string.((1:length(l)).*10).* " %", "Power")
	
	f
end