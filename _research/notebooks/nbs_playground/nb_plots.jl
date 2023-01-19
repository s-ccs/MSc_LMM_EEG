### A Pluto.jl notebook ###
# v0.19.19

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 34593302-70b5-11ed-1157-57dff6b8df66
using Pkg; Pkg.activate("/Users/luis/test")

# ╔═╡ 396539fd-af27-4acb-9c2e-c3e29aa5ab28
using DrWatson

# ╔═╡ 03f74299-8bbc-40bc-9599-d32f011ce3eb
using CairoMakie

# ╔═╡ 3a2accfa-055b-40b2-a41f-fd9c100c12bf
using DelimitedFiles

# ╔═╡ 8bc17027-e6ff-4cfb-9003-3911fa13155e
using TopoPlots

# ╔═╡ 1b6121d7-6385-44ad-8472-ca8795c95299
using ColorSchemes

# ╔═╡ b87eafa8-39f0-4d6f-9481-7162df53b318
using Statistics

# ╔═╡ 01fe9c43-912a-401a-a105-0e92781dc858
md"# Imports"

# ╔═╡ 4de9bab9-b82d-4829-b838-f9b6d9f5206b
CairoMakie.activate!()

# ╔═╡ 85826e04-0177-4e96-a1fb-115531cdfa49
begin
	theme = Theme(fontsize = 20)
	set_theme!(theme)
end

# ╔═╡ d1944a84-8787-495c-9146-bf3f26108e99
import PlutoUI

# ╔═╡ 86286228-3b74-42c1-a772-4a50aa1c8e69
md"# Script"

# ╔═╡ 6446c9a6-f7c7-4d6e-90ca-62eb2252e4f2
md"# Topoplots"

# ╔═╡ 7922d1f3-b2bf-494a-a41e-181d2283ae8b
files = readdir("/Users/luis/Desktop/final/ex1//power", join=true)

# ╔═╡ b8ad35dc-7d12-4ef7-a680-832b255469f5
function parse_range(range_str)
	split_str = (parse.(Int, split(range_str, ":"))...,)
	return (length(split_str) == 2) ? (split_str[1]:split_str[2]) : (split_str[1]:split_str[2]:split_str[3])
end

# ╔═╡ ed293f20-0a47-45b9-a9f8-38c88ada175f
file = files[1]

# ╔═╡ 9e9d9601-dd43-4346-a07e-4a00c74a2663
md"# Examples"

# ╔═╡ 9f663e38-8514-45b1-b7a2-b03400487565
let
	#file = files[4]
	P=readdlm(file, ',', Float64, '\n')
	
	p = parse_savename(file)
	params_str = p[2]
	
	nsubj = parse_range(params_str["nsubjs"])
	nitem = parse_range(params_str["nitems"])

	
	m = zeros(length(nsubj)+1,  length(nitem)+1)

	m[2:end, 2:end] = P

	# construct subtitle


	@unpack β, σranef, σres, noisetype, noiselevel, model = params_str
	s1 = savename(@dict β σranef σres; connector="   |   ", equals=" = ", 
		sort=true, digits=5)
	s2 = savename(@dict noisetype noiselevel model; connector="   |   ", 
		equals=" = ", sort=true, digits=5)
	subtitle = s1 * " \n " * s2

	f = Figure(
		backgroundcolor = :white,
		resolution = (1000, 1000),
		figure_padding = 20
	)

	Axis(
		f[1, 1],
		title = "Power Contour",
		xlabel = "Number of Subjects",
		ylabel = "Number of Items",
		subtitle = subtitle,
		subtitlesize = 25.0f0,
		subtitlegap = 10,
		titlegap = 30,
		xautolimitmargin = (0.0, 0.0),
		xminorticksvisible = true,
		xminorticks = IntervalsBetween(5),
		xticks=0:5:maximum(nsubj),
		xlabelpadding = 20,
		xlabelfont="TeX Gyre Heros Makie Bold",

		yautolimitmargin = (0.0, 0.0),
		yminorticksvisible = true,
		yminorticks = IntervalsBetween(5),
		yticks=0:5:maximum(nitem),
		ylabelpadding = 20,
		ylabelfont="TeX Gyre Heros Makie Bold"
	)

	xlims!(0,maximum(nsubj))
	ylims!(0,maximum(nitem))

	c = collect(reverse(cgrad(:Blues, 10)))[1:10];
	c = [(ci,1) for ci in c]

	# helper code for legend
	g = Figure(resolution = (800, 600))
	Axis(g[1,1])
	l = []
	for i in 1:10
	lin = lines!(g[1,1], 1:10, rand(10), color=c[i][1], linewidth=(i==8 ? 5 : 2))
	push!(l, lin)
	end

	#xs = LinRange(0, maximum(nsubj), length(nsubj) + dxs)
	#ys = LinRange(0, maximum(nitem), length(nitem) + dys)

	xs = LinRange((minimum(nsubj)), maximum(nsubj), length(nsubj))
	xs = [0.0; collect(xs)]

	ys = LinRange((minimum(nitem)), maximum(nitem), length(nitem))
	ys = [0.0; collect(ys)]

	zs = m

	c2 = repeat([(c[8], 0)], 10)
	c2[8] = (c[8], 1)

	points = [Point(x, y) for x in xs, y in ys]
	m

	interpolation=SplineInterpolator(;kx=4, ky=4, smoothing=1000)
	#interpolation=DelaunayMesh()
	#interpolation=ClaughTochter(fill_value=NaN, tol=1, maxiter=1, rescale=false)
	#interpolation=NullInterpolator()
    ct = collect(reverse(cgrad(:Dark2, 10)))[1:10];
	
	t1 = topoplot!(f[1,1], vec(m), vec(points);
		interpolation=interpolation,
		colormap=cgrad([:transparent, :transparent]),#((cgrad(:Blues,20)[10:end])),
			contours=(
				color=c,#:white, 
				linewidth=2, 
				levels=[10,20,30,40,50,60,70,80,90,95]
			), 
		#label_scatter=true, 
		bounding_geometry=Rect,
		enlarge=1.0,
		label_scatter=false	
	)

	t2 = topoplot!(f[1,1], vec(m), vec(points);
		interpolation=interpolation,
		colormap=cgrad([:transparent, :transparent]),#((cgrad(:Blues,20)[10:end])),
			contours=(
				color=c2,#:white, 
				linewidth=8, 
				levels=[10,20,30,40,50,60,70,80,90,95]
			), 
		#label_scatter=true, 
		bounding_geometry=Rect,
		enlarge=1.0,
		label_scatter=false
			
	)

	if false
		contour!(f[1,1], xs, ys, zs,
			levels=[10,20,30,40,50,60,70,80,90,95],
			color=:black,
			linewidth = 2,
			alpha=1,
			transparency = true,
		)
	end


	points = [collect(Iterators.product(round.(Int, collect(xs)), round.(Int, collect(ys))))...]

	if false
		scatter!(f[1,1],points, marker=:xcross, color=:red)
	
		for (x,y) in points
			#((x-1) % 4) != 0 && continue 
			#(y % 4) != 0 && continue 
			
			xi = x ÷ step(nsubj) + 1 
			xi = (x==0 ? xi : xi+1)
			yi = y ÷ step(nitem) + 1 
			yi = (y==0 ? yi : yi+1)
	
			dx = ((minimum(nsubj) .% step(nsubj)) ÷ minimum(nsubj)) + ((step(nsubj) - minimum(nsubj)) ÷ step(nsubj))
			xi = x ÷ step(nsubj) + dx
			xi = (x == 0 ? 1 : xi + 1)
	
			dy = ((minimum(nitem) .% step(nitem)) ÷ minimum(nitem)) + ((step(nitem) - minimum(nitem)) ÷ step(nitem))
			yi = y ÷ step(nitem) + dy
			yi = (y == 0 ? 1 : yi + 1)
	
			value = string.(round(zs[xi,yi], digits=1))
			text!(f[1,1], value, position=(x,y), space = :data, align=(:center, :center), textsize=12)
		end
	end

	Legend(f[1, 2], l, " " .* string.((1:length(l)).*10).* " %", "Power")

	if false
		path = mkpath("/Users/luis/Desktop/exampleplots/")
		fname = replace(file, ".csv"=>".png", p[1]=>"")
		save(path*"/topoplot-"*fname, f)
	end

	#translate!(t1, 0, 0, -100)
	#translate!(t2, 0, 0, -99)

	f
end

# ╔═╡ 480bff80-55c3-411e-b829-8fa2b95550f0
# ╠═╡ disabled = true
#=╠═╡
let
	#file = files[11]
	P=readdlm(file, ',', Float64, '\n')
	
	p = parse_savename(file)
	params_str = p[2]
	
	nsubj = parse_range(params_str["nsubjs"])
	nitem = parse_range(params_str["nitems"])

	
	m = zeros(length(nsubj)+1,  length(nitem)+1)

	m[2:end, 2:end] = P

	# construct subtitle


	@unpack β, σranef, σres, noisetype, noiselevel, model = params_str
	s1 = savename(@dict β σranef σres; connector="   |   ", equals=" = ", 
		sort=true, digits=5)
	s2 = savename(@dict noisetype noiselevel model; connector="   |   ", 
		equals=" = ", sort=true, digits=5)
	subtitle = s1 * " \n " * s2

	f = Figure(
		backgroundcolor = :white,
		resolution = (1000, 1000),
		figure_padding = 20
	)

	Axis(
		f[1, 1],
		title = "Power Contour",
		xlabel = "Number of Subjects",
		ylabel = "Number of Items",
		subtitle = subtitle,
		subtitlesize = 25.0f0,
		subtitlegap = 10,
		titlegap = 30,
		xautolimitmargin = (0.0, 0.0),
		xminorticksvisible = true,
		xminorticks = IntervalsBetween(5),
		xticks=0:5:maximum(nsubj),
		xlabelpadding = 20,
		xlabelfont="TeX Gyre Heros Makie Bold",

		yautolimitmargin = (0.0, 0.0),
		yminorticksvisible = true,
		yminorticks = IntervalsBetween(5),
		yticks=0:5:maximum(nitem),
		ylabelpadding = 20,
		ylabelfont="TeX Gyre Heros Makie Bold"
	)

	xlims!(0,maximum(nsubj))
	ylims!(0,maximum(nitem))

	c = collect(reverse(cgrad(:Blues, 10)))[1:10];
	c = [(ci,1) for ci in c]

	# helper code for legend
	g = Figure(resolution = (800, 600))
	Axis(g[1,1])
	l = []
	for i in 1:10
		lin = lines!(g[1,1], 1:10, rand(10), color=c[i][1], linewidth=(i==8 ? 5 : 2))
		push!(l, lin)
	end

	#xs = LinRange(0, maximum(nsubj), length(nsubj) + dxs)
	#ys = LinRange(0, maximum(nitem), length(nitem) + dys)

	xs = LinRange((minimum(nsubj)), maximum(nsubj), length(nsubj))
	xs = [0.0; collect(xs)]

	ys = LinRange((minimum(nitem)), maximum(nitem), length(nitem))
	ys = [0.0; collect(ys)]

	zs = m

	contour!(f[1,1], xs, ys, zs,
		levels=[10,20,30,40,50,60,70,80,90,95],
		color=c,
		linewidth = 2,
		alpha=1,
		transparency = true,
	)

	c2 = repeat([(c[8], 0)], 10)
	c2[8] = (c[8], 1)

	contour!(f[1,1], xs, ys, zs,
		levels=[10,20,30,40,50,60,70,80,90,95],
		color=c2,
		linewidth = 8,
		alpha=1,
		transparency = true,
	)


	points = [collect(Iterators.product(round.(Int, collect(xs)), round.(Int, collect(ys))))...]
	
	scatter!(f[1,1],points, marker=:xcross, color=:red)

	for (x,y) in points
		#((x-1) % 4) != 0 && continue 
		#(y % 4) != 0 && continue 
		
		xi = x ÷ step(nsubj) + 1 
		xi = (x==0 ? xi : xi+1)
		yi = y ÷ step(nitem) + 1 
		yi = (y==0 ? yi : yi+1)

		dx = ((minimum(nsubj) .% step(nsubj)) ÷ minimum(nsubj)) + ((step(nsubj) - minimum(nsubj)) ÷ step(nsubj))
		xi = x ÷ step(nsubj) + dx
		xi = (x == 0 ? 1 : xi + 1)

		dy = ((minimum(nitem) .% step(nitem)) ÷ minimum(nitem)) + ((step(nitem) - minimum(nitem)) ÷ step(nitem))
		yi = y ÷ step(nitem) + dy
		yi = (y == 0 ? 1 : yi + 1)

		value = string.(round(zs[xi,yi], digits=1))
		text!(f[1,1], value, position=(x,y), space = :data, align=(:center, :center), textsize=12)
	end

	Legend(f[1, 2], l, " " .* string.((1:length(l)).*10).* " %", "Power")
	
	if false
		path = mkpath("/Users/luis/Desktop/exampleplots/")
		fname = replace(file, ".csv"=>".png", p[1]=>"")
		save(path*"/contourplot-"*fname, f)
	end
	
	f
end;
  ╠═╡ =#

# ╔═╡ 0be370e9-a71e-4d7d-b16e-0c100364c60b
md"## Subject intercept - LMM vs Twostage"

# ╔═╡ fd59de14-1c77-4572-a575-d82e1865c87d
md"nsubj $(@bind fnsubj PlutoUI.Slider(3:2:50, default=11, show_value=true))"

# ╔═╡ 256b14b6-e70a-412b-9bc9-323afc35cb3c
savefigures = false

# ╔═╡ 65b459ac-6ae2-4706-a60d-7c01211b1cf4
# ╠═╡ disabled = true
#=╠═╡
let

	fβ = "[2.0, 0.5]"
	fσranef = nothing#"(:subj => [0.0 0.0; 0.0 0.1])"
	fσres = 0.0001
	fnoisetype = "pink"
	fnoiselevel = 1.0
	fmodel = "lmm"

	#fnsubj = 13
	


	# construct subtitle
	β, σranef, σres, noisetype, noiselevel, model, nsubj = fβ, fσranef, fσres, fnoisetype, fnoiselevel, fmodel, fnsubj 
	s1 = savename(@dict nsubj β σranef σres; connector="   |   ", equals=" = ", 
		sort=true, digits=5)
	s2 = savename(@dict noisetype noiselevel model; connector="   |   ", 
		equals=" = ", sort=true, digits=5)
	subtitle = s1 * " \n " * s2

	nsubj = 3:2:50
	nitem = 2:2:50

	f = Figure(
		backgroundcolor = :white,
		resolution = (1000, 800),
		figure_padding = 20
	)
	
	ax = Axis(
		f[1, 1],
		title = "Power",
		titlesize = 30,
		xlabel = "Number of Items",
		ylabel = "Power",
		subtitle = subtitle,
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
	
	for exp in readdir("/Users/luis/Desktop/final/", join=true)[2:2]
		files = readdir(exp*"/power", join=true)

		
		
		for file in files
			!endswith(file, ".csv") && continue

			p = parse_savename(file)
			params_str = p[2]

			@unpack β, σranef, σres, noisetype, noiselevel, model = params_str

			# filter 
			fβ != nothing && fβ != β  && continue
			fσranef  != nothing && fσranef != σranef  && continue
			fσres != nothing && fσres != σres  && continue
			fnoisetype != nothing && fnoisetype != noisetype  && continue
			fnoiselevel != nothing && fnoiselevel != noiselevel  && continue
			fmodel != nothing && fmodel != model  && continue

			#!all(x) && continue

			
			P = readdlm(file, ',', Float64, '\n')
			
			lines!(collect(nitem), P[indexin(fnsubj, nsubj)[1],:], label=σranef)
		
			
			@info β, σranef, σres, noisetype, noiselevel, model
		end
	end

	
	
	Legend(f[1,2], ax, "σranef")

	if savefigures
		path = mkpath("/Users/luis/Desktop/results/plots")
		d = @dict fnsubj fmodel fβ fσranef fσres fnoisetype fnoiselevel
		sname = savename(d, ".png")
		#fname = replace(file, ".csv"=>".png", p[1]=>"")
		save(path*"/subj-int-"*sname, f)
	end
	
	f
end;
  ╠═╡ =#

# ╔═╡ 3066d261-b31c-4965-9447-0ac0f36a086b
# ╠═╡ disabled = true
#=╠═╡
let

	fβ = "[2.0, 0.5]"
	fσranef = nothing#"(:subj => [0.0 0.0; 0.0 0.1])"
	fσres = 0.0001
	fnoisetype = "pink"
	fnoiselevel = 1.0
	fmodel = "twostage"

	#fnsubj = 13
	


	# construct subtitle
	β, σranef, σres, noisetype, noiselevel, model, nsubj = fβ, fσranef, fσres, fnoisetype, fnoiselevel, fmodel, fnsubj 
	s1 = savename(@dict nsubj β σranef σres; connector="   |   ", equals=" = ", 
		sort=true, digits=5)
	s2 = savename(@dict noisetype noiselevel model; connector="   |   ", 
		equals=" = ", sort=true, digits=5)
	subtitle = s1 * " \n " * s2

	nsubj = 3:2:50
	nitem = 2:2:50

	f = Figure(
		backgroundcolor = :white,
		resolution = (1000, 800),
		figure_padding = 20
	)
	
	ax = Axis(
		f[1, 1],
		title = "Power",
		titlesize = 30,
		xlabel = "Number of Items",
		ylabel = "Power",
		subtitle = subtitle,
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
	
	for exp in readdir("/Users/luis/Desktop/final/", join=true)[2:2]
		files = readdir(exp*"/power", join=true)

		
		
		for file in files
			!endswith(file, ".csv") && continue

			p = parse_savename(file)
			params_str = p[2]

			@unpack β, σranef, σres, noisetype, noiselevel, model = params_str

			# filter 
			fβ != nothing && fβ != β  && continue
			fσranef  != nothing && fσranef != σranef  && continue
			fσres != nothing && fσres != σres  && continue
			fnoisetype != nothing && fnoisetype != noisetype  && continue
			fnoiselevel != nothing && fnoiselevel != noiselevel  && continue
			fmodel != nothing && fmodel != model  && continue

			#!all(x) && continue

			
			P = readdlm(file, ',', Float64, '\n')
			
			lines!(collect(nitem), P[indexin(fnsubj, nsubj)[1],:], label=σranef)
		
			
			@info β, σranef, σres, noisetype, noiselevel, model
		end
	end

	
	
	Legend(f[1,0], ax, "σranef")

	if savefigures
		path = mkpath("/Users/luis/Desktop/results/plots")
		d = @dict fnsubj fmodel fβ fσranef fσres fnoisetype fnoiselevel
		sname = savename(d, ".png")
		#fname = replace(file, ".csv"=>".png", p[1]=>"")
		save(path*"/subj-int-"*sname, f)
	end
	
	f
end;
  ╠═╡ =#

# ╔═╡ 6d02bbef-c2c7-44ee-82a9-5b64b5caca81
md"## Subject slope - LMM vs twostage"

# ╔═╡ 3e3d3cd0-061f-4611-8d88-39514f1bc3d5
# ╠═╡ disabled = true
#=╠═╡
let

	fβ = "[2.0, 0.5]"
	fσranef = nothing#"(:subj => [0.0 0.0; 0.0 0.1])"
	fσres = 0.0001
	fnoisetype = "pink"
	fnoiselevel = 1.0
	fmodel = "lmm"

	#fnsubj = 13
	


	# construct subtitle
	β, σranef, σres, noisetype, noiselevel, model, nsubj = fβ, fσranef, fσres, fnoisetype, fnoiselevel, fmodel, fnsubj 
	s1 = savename(@dict nsubj β σranef σres; connector="   |   ", equals=" = ", 
		sort=true, digits=5)
	s2 = savename(@dict noisetype noiselevel model; connector="   |   ", 
		equals=" = ", sort=true, digits=5)
	subtitle = s1 * " \n " * s2

	nsubj = 3:2:50
	nitem = 2:2:50

	f = Figure(
		backgroundcolor = :white,
		resolution = (1000, 800),
		figure_padding = 20
	)
	
	ax = Axis(
		f[1, 1],
		title = "Power",
		titlesize = 30,
		xlabel = "Number of Items",
		ylabel = "Power",
		subtitle = subtitle,
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
	
	for exp in readdir("/Users/luis/Desktop/final/", join=true)[4:4]
		files = readdir(exp*"/power", join=true)

		
		
		for file in files
			!endswith(file, ".csv") && continue

			p = parse_savename(file)
			params_str = p[2]

			@unpack β, σranef, σres, noisetype, noiselevel, model = params_str

			# filter 
			fβ != nothing && fβ != β  && continue
			fσranef  != nothing && fσranef != σranef  && continue
			fσres != nothing && fσres != σres  && continue
			fnoisetype != nothing && fnoisetype != noisetype  && continue
			fnoiselevel != nothing && fnoiselevel != noiselevel  && continue
			fmodel != nothing && fmodel != model  && continue

			#!all(x) && continue

			
			P = readdlm(file, ',', Float64, '\n')
			
			lines!(collect(nitem), P[indexin(fnsubj, nsubj)[1],:], label=σranef)
		
			
			@info β, σranef, σres, noisetype, noiselevel, model
		end
	end

	
	
	Legend(f[1,2], ax, "σranef")


	if savefigures
		path = mkpath("/Users/luis/Desktop/results/plots")
		d = @dict fnsubj fmodel fβ fσranef fσres fnoisetype fnoiselevel
		sname = savename(d, ".png")
		#fname = replace(file, ".csv"=>".png", p[1]=>"")
		save(path*"/subj-slope-"*sname, f)
	end
	
	f
end;
  ╠═╡ =#

# ╔═╡ c5684c71-ec5c-48d3-b202-6169f159d190
# ╠═╡ disabled = true
#=╠═╡
let

	fβ = "[2.0, 0.5]"
	fσranef = nothing#"(:subj => [0.0 0.0; 0.0 0.1])"
	fσres = 0.0001
	fnoisetype = "pink"
	fnoiselevel = 1.0
	fmodel = "twostage"

	#fnsubj = 13
	


	# construct subtitle
	β, σranef, σres, noisetype, noiselevel, model, nsubj = fβ, fσranef, fσres, fnoisetype, fnoiselevel, fmodel, fnsubj 
	s1 = savename(@dict nsubj β σranef σres; connector="   |   ", equals=" = ", 
		sort=true, digits=5)
	s2 = savename(@dict noisetype noiselevel model; connector="   |   ", 
		equals=" = ", sort=true, digits=5)
	subtitle = s1 * " \n " * s2

	nsubj = 3:2:50
	nitem = 2:2:50

	f = Figure(
		backgroundcolor = :white,
		resolution = (1000, 800),
		figure_padding = 20
	)
	
	ax = Axis(
		f[1, 1],
		title = "Power",
		titlesize = 30,
		xlabel = "Number of Items",
		ylabel = "Power",
		subtitle = subtitle,
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
	
	for exp in readdir("/Users/luis/Desktop/final/", join=true)[4:4]
		files = readdir(exp*"/power", join=true)

		
		
		for file in files
			!endswith(file, ".csv") && continue

			p = parse_savename(file)
			params_str = p[2]

			@unpack β, σranef, σres, noisetype, noiselevel, model = params_str

			# filter 
			fβ != nothing && fβ != β  && continue
			fσranef  != nothing && fσranef != σranef  && continue
			fσres != nothing && fσres != σres  && continue
			fnoisetype != nothing && fnoisetype != noisetype  && continue
			fnoiselevel != nothing && fnoiselevel != noiselevel  && continue
			fmodel != nothing && fmodel != model  && continue

			#!all(x) && continue

			
			P = readdlm(file, ',', Float64, '\n')
			
			lines!(collect(nitem), P[indexin(fnsubj, nsubj)[1],:], label=σranef)
		
			
			@info β, σranef, σres, noisetype, noiselevel, model
		end
	end

	
	
	Legend(f[1,0], ax, "σranef")


	if savefigures
		path = mkpath("/Users/luis/Desktop/results/plots")
		d = @dict fnsubj fmodel fβ fσranef fσres fnoisetype fnoiselevel
		sname = savename(d, ".png")
		#fname = replace(file, ".csv"=>".png", p[1]=>"")
		save(path*"/subj-slope-"*sname, f)
	end
	
	f
end;
  ╠═╡ =#

# ╔═╡ 0b4348fc-52d3-4006-bca5-bab0bce8d5bd
let

	fβ = "[2.0, 0.5]"
	fσranef = nothing#"(:subj => [0.0 0.0; 0.0 0.1])"
	fσres = 0.0001
	fnoisetype = "pink"
	fnoiselevel = 1.0
	#fmodel = "lmm"

	fnsubj = 21
	


	# construct subtitle
	β, σranef, σres, noisetype, noiselevel, nsubj = fβ, fσranef, fσres, fnoisetype, fnoiselevel, fnsubj 
	s1 = savename(@dict nsubj β σranef σres; connector="   |   ", equals=" = ", 
		sort=true, digits=5)
	s2 = savename(@dict noisetype noiselevel; connector="   |   ", 
		equals=" = ", sort=true, digits=5)
	subtitle = s1 * " \n " * s2

	nsubj = 3:2:50
	nitem = 2:2:50

	f = Figure(
		backgroundcolor = :white,
		resolution = (1500, 800),
		figure_padding = 20
	)
	
	ax1 = Axis(
		aspect=1,
		f[1, 2],
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

	ax2 = Axis(
		aspect=1,
		f[1, 1],
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

	dir = "/Users/luis/Desktop/masterthesis/data/experiments/"
	files = readdir(dir*"power", join=true)

	
	for fmodel in ["lmmperm", "twostage"]
		
		
		
		for file in files
			#@show file
			!endswith(file, ".csv") && continue
	
			p = parse_savename(file)
			params_str = p[2]
	
			@unpack β, σranef, σres, noisetype, noiselevel, model = params_str
	
			# filter 
			fβ != nothing && fβ != β  && continue
			fσranef  != nothing && fσranef != σranef  && continue
			fσres != nothing && fσres != σres  && continue
			fnoisetype != nothing && fnoisetype != noisetype  && continue
			fnoiselevel != nothing && fnoiselevel != noiselevel  && continue
			fmodel != nothing && fmodel != model  && continue

			# test
			!startswith(σranef, "(:subj => [0.0") && continue
			endswith(σranef, "0.0 0.0])") && continue
			endswith(σranef, "0.0 0.2])") && continue
			endswith(σranef, "0.0 0.4])") && continue
			endswith(σranef, "0.0 1.5])") && continue
			endswith(σranef, "0.0 4.0])") && continue
	
			#!all(x) && continue
	
			@show file
			P = readdlm(file, ',', Float64, '\n')
	
			ax = (fmodel == "lmmperm" ? ax1 : ax2)
			lines!(ax, collect(nitem), P[indexin(fnsubj, nsubj)[1],:], label=σranef)

			
			
			@info β, σranef, σres, noisetype, noiselevel, model
		end
	end

	#@unpack β, σranef, σres, noisetype, noiselevel, model = params_str
	nsubj=fnsubj
	noiselevel=fnoiselevel
	s1 = savename(@dict nsubj β σres; connector="   |   ", 
		equals=" = ", sort=true, digits=5)
	s2 = savename(@dict noisetype noiselevel; connector="   |   ", 		equals=" = ", sort=true, digits=5)
	subtitle = s1 * " \n " * s2

	f[0, :] = Label(f, subtitle, textsize=30, font="TeX Gyre Heros Makie")
	f[-1, :] = Label(f, "Power (Two-Stage vs. LMM)", textsize=40, font="TeX Gyre Heros Makie Bold", padding=(0,0,0,0))
	
	Legend(f[1,3], ax2, "σranef")
	

	#supertitle = Label(f[0, :], subtitle, textsize=30)

	if true
			path =mkpath(dir * "plots-overleaf")
			d = @dict nsubj β σres noisetype noiselevel
			sname = savename(d, ".png")
			fname = replace(sname, 
				".csv"=>".png", 
				#p[1]=>"",
				"β" => "beta",
				"σranef" => "ranef",
				"σres" => "res",
				"model=lmmperm"=>""
			)
			save(dir * "plots-overleaf" * "/single-"*fname, f)
		end
	
	f
	
end

# ╔═╡ 437645da-2a7c-4cce-bd09-9e8d6ea08f88


# ╔═╡ 699bf2c2-7fa2-4027-bf05-a93900650dc6
md"## Effect size - LMM vs twostage"

# ╔═╡ 48f09c8f-5663-4f5f-8926-112487a4e043
begin
	fβ = nothing#"[2.0, 0.5]"
	fσranef = "(:subj => [0.0 0.0; 0.0 0.1])"
	fσres = 0.0001
	fnoisetype = "pink"
	fnoiselevel = 1.0
end;

# ╔═╡ 36399c3f-fc40-44b5-8ff2-e9f6b042be3e


# ╔═╡ 4e0afdaa-9284-4e29-89fa-2b82ffb1c0fd
# ╠═╡ disabled = true
#=╠═╡
let

	#fβ = nothing#"[2.0, 0.5]"
	#fσranef = "(:subj => [0.0 0.0; 0.0 0.5])"
	#fσres = 0.0001
	#fnoisetype = "pink"
	#fnoiselevel = 1.0
	fmodel = "twostage"

	#fnsubj = 13
	

	# construct subtitle
	β, σranef, σres, noisetype, noiselevel, model, nsubj = fβ, fσranef, fσres, fnoisetype, fnoiselevel, fmodel, fnsubj 
	
	s1 = savename(@dict β nsubj σranef σres; connector="   |   ", equals=" = ", 
		sort=true, digits=5)
	s2 = savename(@dict noisetype noiselevel model; connector="   |   ", 
		equals=" = ", sort=true, digits=5)
	subtitle = s1 * " \n " * s2

	nsubj = 3:2:50
	nitem = 2:2:50

	f = Figure(
		backgroundcolor = :white,
		resolution = (1000, 800),
		figure_padding = 20
	)
	
	ax = Axis(
		f[1, 1],
		title = "Power",
		titlesize = 30,
		xlabel = "Number of Items",
		ylabel = "Power",
		subtitle = subtitle,
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
	
	for exp in readdir("/Users/luis/Desktop/final/", join=true)[4:4]
		files = readdir(exp*"/power", join=true)

		for file in files
			!endswith(file, ".csv") && continue

			p = parse_savename(file)
			params_str = p[2]

			@unpack β, σranef, σres, noisetype, noiselevel, model = params_str

			# filter 
			fβ != nothing && fβ != β  && continue
			fσranef  != nothing && fσranef != σranef  && continue
			fσres != nothing && fσres != σres  && continue
			fnoisetype != nothing && fnoisetype != noisetype  && continue
			fnoiselevel != nothing && fnoiselevel != noiselevel  && continue
			fmodel != nothing && fmodel != model  && continue

			#!all(x) && continue

			
			P = readdlm(file, ',', Float64, '\n')
			
			lines!(collect(nitem), P[indexin(fnsubj, nsubj)[1],:], label=β)
		
			
			@info β, σranef, σres, noisetype, noiselevel, model
		end
	end

	
	
	Legend(f[1,0], ax, "β")

	if savefigures
		path = mkpath("/Users/luis/Desktop/results/plots")
		d = @dict fnsubj fmodel fβ fσranef fσres fnoisetype fnoiselevel
		sname = savename(d, ".png")
		#fname = replace(file, ".csv"=>".png", p[1]=>"")
		save(path*"/effect-size-"*sname, f)
	end
	
	f
end;
  ╠═╡ =#

# ╔═╡ 6eb36c84-cec3-4751-9550-aaf097425eb8
readdir("/Users/luis/Desktop/final/", join=true)

# ╔═╡ 0ec89d1f-f5d1-4d28-9002-9b2d8d47e189
md"# Script filename"

# ╔═╡ 0a5faf2a-c1ea-43a6-9f84-9255cc39af27
let
	dir = "/Users/luis/Desktop/masterthesis/data/experiments/plots/"
	src = "/Users/luis/Desktop/masterthesis/data/experiments/plots-overleaf/"
	mkdir(src)
	
	for file in readdir(dir, join=false)
		!endswith(file, ".png") && continue
		
		newfile = replace(file, 
			"β" => "beta",
			"σranef" => "ranef",
			"σres" => "res"
		)

		mv(dir*file, src*newfile, force=true)
	end
end

# ╔═╡ 4a04ad4a-7502-4844-b7aa-46518190f811
md"# Sanity check"

# ╔═╡ cada7a76-ad50-4b3b-8621-74bc266b7d5a
cgrad(:thermal, rev = true, 30)

# ╔═╡ 4e54f501-16ea-49aa-a7c2-a969ed5fdd0b


# ╔═╡ 10794927-d724-4bd4-a7f8-ffca4ab18f5a
let
	# construct subtitle
	#β, σranef, σres, noisetype, noiselevel, model, nsubj = fβ, fσranef, fσres, fnoisetype, fnoiselevel, fmodel, fnsubj 
	#s1 = savename(@dict nsubj β σranef σres; connector="   |   ", equals=" = ", 
	#	sort=true, digits=5)
	#s2 = savename(@dict noisetype noiselevel model; connector="   |   ", 
	#	equals=" = ", sort=true, digits=5)
	#subtitle = s1 * " \n " * s2

	nsubj = 3:2:50
	nitem = 2:2:50

	

	figs = []
	
	for exp in readdir("/Users/luis/Desktop/masterthesis/data/sanitycheck", join=true)[5:5]
		@show exp
		files = readdir(exp, join=true)

		
		
		for file in files
			!endswith(file, ".csv") && continue
			@show file

			p = parse_savename(file)
			params_str = p[2]
			@unpack β, σranef, σres, noisetype, noiselevel, model = params_str
			s1 = savename(@dict nsubj β σranef σres; connector="   |   ", 
				equals=" = ", sort=true, digits=5)
			s2 = savename(@dict noisetype noiselevel model; connector="   |   ", 		equals=" = ", sort=true, digits=5)
			subtitle = s1 * " \n " * s2

			f = Figure(
				backgroundcolor = :white,
				resolution = (1000, 930),
				figure_padding = 10
			)
			
			ax = Axis(
				aspect=1,
				f[1, 1],
				title = "Type 1 Error",
				titlesize = 30,
				xlabel = "Number of Items",
				ylabel = "Probability",
				subtitle = subtitle,
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
				yminorticks = IntervalsBetween(10),
				yticks=0:5:maximum(100),
				ylabelpadding = 20,
				ylabelfont="TeX Gyre Heros Makie Bold",
				ylabelsize=25
			)

			xlims!(0,maximum(nitem))
			ylims!(0,20)

			p = parse_savename(file)
			params_str = p[2]

			@unpack β, σranef, σres, noisetype, noiselevel, model = params_str
			
			"twostage" != model  && continue
			

			
			P = readdlm(file, ',', Float64, '\n')

			labels = [string(i) for i in nsubj][begin:1:end]
			series!(nitem, P[begin:1:end,:], color=collect(cgrad(:thermal, rev = true, categorical = true, 30)), alpha=0.5, labels=labels)

			Legend(f[1,2], ax, "Number of\n subjects")
		
			
			@info β, σranef, σres, noisetype, noiselevel, model

			if false
				path =mkpath("/Users/luis/Desktop/masterthesis/data/sanitycheck/plots")
				fname = replace(file, 
					".csv"=>".png", 
					p[1]=>"",
					"β" => "beta",
					"σranef" => "ranef",
					"σres" => "res"
				)
				save(path*"/type1-"*fname, f)
			end
		
			push!(figs, f)
		end
	end

	
	
	

	
	
	figs[1]
end

# ╔═╡ 8a324c9d-b17e-4d89-b2d3-b349b7e6b10f


# ╔═╡ 83e41c0c-acf2-45d5-a326-1f36101cdc96
length(3:4:50)

# ╔═╡ 5a6a8358-6e01-40a0-919e-5f12943a0593


# ╔═╡ 877057b1-0f02-48f7-8d1b-8a673d4a6b64
md"# Triplet LMM vs Twostage"

# ╔═╡ 44e2efab-0cc7-4731-9593-7243af2e6f5f
let
	dir = "/Users/luis/Desktop/masterthesis/data/experiments/"
	files = readdir(dir*"power", join=true)
	file = files[10]
	p = parse_savename(file)
    params_str = p[2]
	parse_range(params_str["nitems"])
end

# ╔═╡ 26adff27-79d6-4f86-b4e9-28189cb2af97


# ╔═╡ 36aa43fe-5842-417a-a5e9-fc921116edd4
co = cgrad([:darkred, :darkred, :red, :white,:white, :blue, :darkblue, :darkblue], categorical = true, rev=true, 16)

# ╔═╡ 9e9116f8-58be-44f2-b3e7-58d91e28d276
# ╠═╡ disabled = true
#=╠═╡
let
	#nsubj = 5:5:100#3:2:50
	#nitem = 2:4:100#2:2:50
	nsubj = 3:2:50
	nitem = 2:2:50

	dir = "/Users/luis/Desktop/masterthesis/data/experiments/"
	files = readdir(dir*"power", join=true)

	figs = []
	
	for file in files[begin:174]
		@show file
		!endswith(file, ".csv") && continue
		#!endswith(file, ".csv") && continue

		f = Figure(
			backgroundcolor = :white,
			resolution = (2000, 800),
			figure_padding = (0,0,50,0)
		)
	
		ax1 = Axis(f[1, 1], aspect=1,
			title = "Two-Stage",
			titlesize = 30,
			xlabel = "Number of Subjects",
			ylabel = "Number of Items",
			titlegap = 30,
			xautolimitmargin = (0.0, 0.0),
			xminorticksvisible = true,
			#xminorticks = IntervalsBetween(5),
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
	
		ax2 = Axis(f[1, 2], aspect=1,
			title = "LMM",
			titlesize = 30,
			xlabel = "Number of Subjects",
			ylabel = "Number of Items",
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
	
		ax3 = Axis(f[1, 3], aspect=1,
			title = "Difference",
			titlesize = 30,
			xlabel = "Number of Subjects",
			ylabel = "Number of Items",
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

		p = parse_savename(file)
		params_str = p[2]
		@unpack β, σranef, σres, noisetype, noiselevel, model = params_str
		@show model

		"twostage" != model  && continue

		xs = LinRange((minimum(nsubj)), maximum(nsubj), length(nsubj))
		xs = [0.0; collect(xs)]

		ys = LinRange((minimum(nitem)), maximum(nitem), length(nitem))
		ys = [0.0; collect(ys)]

		c = collect(reverse(cgrad(:Blues, 10)))[1:10];
		c = [(ci,1) for ci in c]

		
		# twostage
		
		P1 = readdlm(file, ',', Float64, '\n')

		p = parse_savename(file)
		
		m1 = zeros(length(nsubj)+1,  length(nitem)+1)

        m1[2:end, 2:end] = P1

		contour!(ax1, xs, ys, m1,
			levels=[10,20,30,40,50,60,70,80,90,95],
			color=c,
			linewidth = 2,
			alpha=1,
			transparency = true,
		)

		c2 = repeat([(c[8], 0)], 10)
		c2[8] = (c[8], 1)
	
		contour!(ax1, xs, ys, m1,
			levels=[10,20,30,40,50,60,70,80,90,95],
			color=c2,
			linewidth = 8,
			alpha=1,
			transparency = true,
		)

		# lmm
		file = replace(file, "model=twostage"=>"model=lmmperm")
		@info file
		
		P2 = readdlm(file, ',', Float64, '\n')
		
		m2 = zeros(length(nsubj)+1,  length(nitem)+1)
        
		m2[2:end, 2:end] = P2
		
		contour!(ax2, xs, ys, m2,
			levels=[10,20,30,40,50,60,70,80,90,95],
			color=c,
			linewidth = 2,
			alpha=1,
			transparency = true,
		)
		contour!(ax2, xs, ys, m2,
			levels=[10,20,30,40,50,60,70,80,90,95],
			color=c2,
			linewidth = 8,
			alpha=1,
			transparency = true,
		)
		
		D = m2 - m1 # P2 - P1

		@info D
	
		h1 = heatmap!(ax3, xs, ys, D, colormap=co, colorrange=(-20,20))
		xlims!(0,maximum(nsubj))
		ylims!(0,maximum(nitem))

		f[-1, :] = Label(f, "Power (Two-Stage vs. LMM)", textsize=40, font="TeX Gyre Heros Makie Bold", padding=(0,0,0,0))

		params_str = p[2]
		@unpack β, σranef, σres, noisetype, noiselevel, model = params_str
		s1 = savename(@dict β σranef; connector="   |   ", 
			equals=" = ", sort=true, digits=5)
		s2 = savename(@dict σres noisetype noiselevel; connector="   |   ", 		equals=" = ", sort=true, digits=5)
		subtitle = s1 * " \n " * s2

		f[0, :] = Label(f, subtitle, textsize=30, font="TeX Gyre Heros Makie")

		Colorbar(f[1, end+1], h1, label="Difference", ticks = -20:5:20)

		# helper code for legend
		g = Figure(resolution = (800, 600))
		Axis(g[1,1])
		l = []
		for i in 1:10
			lin = lines!(g[1,1], 1:10, rand(10), color=c[i][1], linewidth=(i==8 ? 5 : 2))
			push!(l, lin)
		end

		Legend(f[1, 0], l, " " .* string.((1:length(l)).*10).* " %", "Power")

		push!(figs, f)

		if false
			path =mkpath(dir * "plots-overleaf")
			fname = replace(file, 
				".csv"=>".png", 
				p[1]=>"",
				"β" => "beta",
				"σranef" => "ranef",
				"σres" => "res",
				"model=lmmperm"=>""
			)
			save(dir * "plots-overleaf" * "/triplet-"*fname, f)
		end
	end


	
	figs[1]

			
	
end

  ╠═╡ =#

# ╔═╡ ccdeb060-cc6d-4c71-92e5-4fe823233293
let
	#nsubj = 5:5:100#3:2:50
	#nitem = 2:4:100#2:2:50
	nsubj = 3:2:50
	nitem = 2:2:50

	dir = "/Users/luis/Desktop/masterthesis/data/experiments/"
	files = readdir(dir*"power", join=true)

	figs = []
	
	for file in files[begin:174]
		@show file
		!endswith(file, ".csv") && continue
		#!endswith(file, ".csv") && continue

		f = Figure(
			backgroundcolor = :white,
			resolution = (2000, 800),
			figure_padding = (0,0,50,0)
		)
	
		ax1 = Axis(f[1, 1], aspect=1,
			title = "Two-Stage",
			titlesize = 30,
			xlabel = "Number of Subjects",
			ylabel = "Number of Items",
			titlegap = 30,
			xautolimitmargin = (0.0, 0.0),
			xminorticksvisible = true,
			#xminorticks = IntervalsBetween(5),
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
	
		ax2 = Axis(f[1, 2], aspect=1,
			title = "LMM",
			titlesize = 30,
			xlabel = "Number of Subjects",
			ylabel = "Number of Items",
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
	
		ax3 = Axis(f[1, 3], aspect=1,
			title = "Difference (LMM - Two-Stage)",
			titlesize = 30,
			xlabel = "Number of Subjects",
			ylabel = "Number of Items",
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

		p = parse_savename(file)
		params_str = p[2]
		@unpack β, σranef, σres, noisetype, noiselevel, model = params_str
		@show model

		"twostage" != model  && continue

		xs = LinRange((minimum(nsubj)), maximum(nsubj), length(nsubj))
		xs = [0.0; collect(xs)]

		ys = LinRange((minimum(nitem)), maximum(nitem), length(nitem))
		ys = [0.0; collect(ys)]

		c = collect(reverse(cgrad(:Blues, 10)))[1:10];
		c = [(ci,1) for ci in c]

		
		# twostage
		
		P1 = readdlm(file, ',', Float64, '\n')

		p = parse_savename(file)
		
		m1 = zeros(length(nsubj)+1,  length(nitem)+1)

        m1[2:end, 2:end] = P1

		contour!(ax1, xs, ys, m1,
			levels=[10,20,30,40,50,60,70,80,90,95],
			color=c,
			linewidth = 2,
			alpha=1,
			transparency = true,
		)

		c2 = repeat([(c[8], 0)], 10)
		c2[8] = (c[8], 1)
	
		contour!(ax1, xs, ys, m1,
			levels=[10,20,30,40,50,60,70,80,90,95],
			color=c2,
			linewidth = 8,
			alpha=1,
			transparency = true,
		)

		# lmm
		file = replace(file, "model=twostage"=>"model=lmmperm")
		@info file
		
		P2 = readdlm(file, ',', Float64, '\n')
		
		m2 = zeros(length(nsubj)+1,  length(nitem)+1)
        
		m2[2:end, 2:end] = P2
		
		contour!(ax2, xs, ys, m2,
			levels=[10,20,30,40,50,60,70,80,90,95],
			color=c,
			linewidth = 2,
			alpha=1,
			transparency = true,
		)
		contour!(ax2, xs, ys, m2,
			levels=[10,20,30,40,50,60,70,80,90,95],
			color=c2,
			linewidth = 8,
			alpha=1,
			transparency = true,
		)
		
		D = m2 - m1 # P2 - P1

		@info D
	
		h1 = heatmap!(ax3, xs, ys, D, colormap=co, colorrange=(-20,20))
		xlims!(0,maximum(nsubj))
		ylims!(0,maximum(nitem))

		f[-1, :] = Label(f, "Power (Two-Stage vs. LMM)", textsize=40, font="TeX Gyre Heros Makie Bold", padding=(0,0,0,0))

		params_str = p[2]
		@unpack β, σranef, σres, noisetype, noiselevel, model = params_str
		s1 = savename(@dict β σranef; connector="   |   ", 
			equals=" = ", sort=true, digits=5)
		s2 = savename(@dict σres noisetype noiselevel; connector="   |   ", 		equals=" = ", sort=true, digits=5)
		subtitle = s1 * " \n " * s2

		f[0, :] = Label(f, subtitle, textsize=30, font="TeX Gyre Heros Makie")

		Colorbar(f[1, end+1], h1, label="Difference", ticks = -20:5:20)

		# helper code for legend
		g = Figure(resolution = (800, 600))
		Axis(g[1,1])
		l = []
		for i in 1:10
			lin = lines!(g[1,1], 1:10, rand(10), color=c[i][1], linewidth=(i==8 ? 5 : 2))
			push!(l, lin)
		end

		Legend(f[1, 0], l, " " .* string.((1:length(l)).*10).* " %", "Power")

		push!(figs, f)

		if true
			path =mkpath(dir * "plots-overleaf")
			fname = replace(file, 
				".csv"=>".png", 
				p[1]=>"",
				"β" => "beta",
				"σranef" => "ranef",
				"σres" => "res",
				"model=lmmperm"=>""
			)
			save(dir * "plots-overleaf" * "/triplet-"*fname, f)
		end
	end


	
	figs[1]

			
	
end


# ╔═╡ 84f8a000-073d-43d0-a934-792d48e59426
function plot_contour()
	xlims!(0,maximum(nsubj))
	ylims!(0,maximum(nitem))

	c = collect(reverse(cgrad(:Blues, 10)))[1:10];
	c = [(ci,1) for ci in c]

	# helper code for legend
	g = Figure(resolution = (800, 600))
	Axis(g[1,1])
	l = []
	for i in 1:10
		lin = lines!(g[1,1], 1:10, rand(10), color=c[i][1], linewidth=(i==8 ? 5 : 2))
		push!(l, lin)
	end

	#xs = LinRange(0, maximum(nsubj), length(nsubj) + dxs)
	#ys = LinRange(0, maximum(nitem), length(nitem) + dys)

	xs = LinRange((minimum(nsubj)), maximum(nsubj), length(nsubj))
	xs = [0.0; collect(xs)]

	ys = LinRange((minimum(nitem)), maximum(nitem), length(nitem))
	ys = [0.0; collect(ys)]

	zs = m

	contour!(f[1,1], xs, ys, zs,
		levels=[10,20,30,40,50,60,70,80,90,95],
		color=c,
		linewidth = 2,
		alpha=1,
		transparency = true,
	)

	c2 = repeat([(c[8], 0)], 10)
	c2[8] = (c[8], 1)

	contour!(f[1,1], xs, ys, zs,
		levels=[10,20,30,40,50,60,70,80,90,95],
		color=c2,
		linewidth = 8,
		alpha=1,
		transparency = true,
	)

# ╔═╡ 1cedb9fd-048f-40af-81ea-174967026195
let
	dir = "/Users/luis/Desktop/masterthesis/data/experiments/power"
	files = readdir(dir, join=true)
end

# ╔═╡ 07d09ff2-c913-4e57-9d04-34de08f31603
md"# Function"

# ╔═╡ 4a6364de-ea9d-4fec-a6a7-a8c9b842d66b
function plot(file; showscatter=false, savefile=true)
	P=readdlm(file, ',', Float64, '\n')
	
	p = parse_savename(file)
	params_str = p[2]
	
	nsubj = parse_range(params_str["nsubjs"])
	nitem = parse_range(params_str["nitems"])

	
	m = zeros(length(nsubj)+1,  length(nitem)+1)

	m[2:end, 2:end] = P

	# construct subtitle


	@unpack β, σranef, σres, noisetype, noiselevel, model = params_str
	s1 = savename(@dict β σranef σres; connector="   |   ", equals=" = ", 
		sort=true, digits=5)
	s2 = savename(@dict noisetype noiselevel model; connector="   |   ", 
		equals=" = ", sort=true, digits=5)
	subtitle = s1 * " \n " * s2

	f = Figure(
		backgroundcolor = :white,
		resolution = (1000, 1000),
		figure_padding = 20
	)

	Axis(
		f[1, 1],
		title = "Power Contour",
		xlabel = "Number of Subjects",
		ylabel = "Number of Items",
		subtitle = subtitle,
		subtitlesize = 25.0f0,
		subtitlegap = 10,
		titlegap = 30,
		xautolimitmargin = (0.0, 0.0),
		xminorticksvisible = true,
		xminorticks = IntervalsBetween(5),
		xticks=0:5:maximum(nsubj),
		xlabelpadding = 20,
		xlabelfont="TeX Gyre Heros Makie Bold",

		yautolimitmargin = (0.0, 0.0),
		yminorticksvisible = true,
		yminorticks = IntervalsBetween(5),
		yticks=0:5:maximum(nitem),
		ylabelpadding = 20,
		ylabelfont="TeX Gyre Heros Makie Bold"
	)

	xlims!(0,maximum(nsubj))
	ylims!(0,maximum(nitem))

	c = collect(reverse(cgrad(:Blues, 10)))[1:10];
	c = [(ci,1) for ci in c]

	# helper code for legend
	g = Figure(resolution = (800, 600))
	Axis(g[1,1])
	l = []
	for i in 1:10
		lin = lines!(g[1,1], 1:10, rand(10), 
			color=c[i][1], 
			linewidth=(i==8 ? 5 : 2))
		push!(l, lin)
	end

	#xs = LinRange(0, maximum(nsubj), length(nsubj) + dxs)
	#ys = LinRange(0, maximum(nitem), length(nitem) + dys)

	xs = LinRange((minimum(nsubj)), maximum(nsubj), length(nsubj))
	xs = [0.0; collect(xs)]

	ys = LinRange((minimum(nitem)), maximum(nitem), length(nitem))
	ys = [0.0; collect(ys)]

	zs = m

	c2 = repeat([(c[8], 0)], 10)
	c2[8] = (c[8], 1)

	points = [Point(x, y) for x in xs, y in ys]
	m

	interpolation=SplineInterpolator(;kx=4, ky=4, smoothing=1000)
	#interpolation=DelaunayMesh()
	#interpolation=ClaughTochter(fill_value=NaN, tol=1, maxiter=1, rescale=false)
	#interpolation=NullInterpolator()
	
	t1 = topoplot!(f[1,1], vec(m), vec(points);
		interpolation=interpolation,
		colormap=cgrad([:transparent, :transparent]),#((cgrad(:Blues,20)[10:end])),
			contours=(
				color=c,#:white, 
				linewidth=2, 
				levels=[10,20,30,40,50,60,70,80,90,95]
			), 
		#label_scatter=true, 
		bounding_geometry=Rect,
		enlarge=1.0,
		label_scatter=false	
	)

	t2 = topoplot!(f[1,1], vec(m), vec(points);
		interpolation=interpolation,
		colormap=cgrad([:transparent, :transparent]),#((cgrad(:Blues,20)[10:end])),
			contours=(
				color=c2,#:white, 
				linewidth=8, 
				levels=[10,20,30,40,50,60,70,80,90,95]
			), 
		#label_scatter=true, 
		bounding_geometry=Rect,
		enlarge=1.0,
		label_scatter=false
			
	)

	if false
		contour!(f[1,1], xs, ys, zs,
			levels=[10,20,30,40,50,60,70,80,90,95],
			color=:black,
			linewidth = 2,
			alpha=1,
			transparency = true,
		)
	end


	points = [collect(Iterators.product(round.(Int, collect(xs)), round.(Int, collect(ys))))...]

	if showscatter
		scatter!(f[1,1],points, marker=:xcross, color=:red)
	
		for (x,y) in points
			#((x-1) % 4) != 0 && continue 
			#(y % 4) != 0 && continue 
			
			xi = x ÷ step(nsubj) + 1 
			xi = (x==0 ? xi : xi+1)
			yi = y ÷ step(nitem) + 1 
			yi = (y==0 ? yi : yi+1)
	
			dx = ((minimum(nsubj) .% step(nsubj)) ÷ minimum(nsubj)) + ((step(nsubj) - minimum(nsubj)) ÷ step(nsubj))
			xi = x ÷ step(nsubj) + dx
			xi = (x == 0 ? 1 : xi + 1)
	
			dy = ((minimum(nitem) .% step(nitem)) ÷ minimum(nitem)) + ((step(nitem) - minimum(nitem)) ÷ step(nitem))
			yi = y ÷ step(nitem) + dy
			yi = (y == 0 ? 1 : yi + 1)
	
			value = string.(round(zs[xi,yi], digits=1))
			text!(f[1,1], value, position=(x,y), space = :data, align=(:center, :center), textsize=12)
		end
	end

	labels = " " .* string.((1:length(l)).*10).* " %"
	labels = replace(labels, " 100 %"=>" > 95 %")
	Legend(f[1, 2], l, labels, "Power")

	if savefile
		path = mkpath(replace(p[1], "power/"=>"topoplots/"))
		fname = replace(file, ".csv"=>".png", p[1]=>"")
		save(path*"/"*fname, f)
	end
end

# ╔═╡ bfe4445a-7b85-4c8c-8b1e-b8a70b4b9044
let
	if false
		for exp in readdir("/Users/luis/Desktop/final/", join=true)
			files = readdir(exp*"/power", join=true)
			
			for file in files
				!endswith(file, ".csv") && continue
				plot(file; showscatter=false)
			end
		end
	end
end

# ╔═╡ Cell order:
# ╠═01fe9c43-912a-401a-a105-0e92781dc858
# ╠═34593302-70b5-11ed-1157-57dff6b8df66
# ╠═03f74299-8bbc-40bc-9599-d32f011ce3eb
# ╠═4de9bab9-b82d-4829-b838-f9b6d9f5206b
# ╠═3a2accfa-055b-40b2-a41f-fd9c100c12bf
# ╠═396539fd-af27-4acb-9c2e-c3e29aa5ab28
# ╠═8bc17027-e6ff-4cfb-9003-3911fa13155e
# ╠═1b6121d7-6385-44ad-8472-ca8795c95299
# ╠═85826e04-0177-4e96-a1fb-115531cdfa49
# ╠═d1944a84-8787-495c-9146-bf3f26108e99
# ╠═86286228-3b74-42c1-a772-4a50aa1c8e69
# ╠═bfe4445a-7b85-4c8c-8b1e-b8a70b4b9044
# ╟─6446c9a6-f7c7-4d6e-90ca-62eb2252e4f2
# ╠═7922d1f3-b2bf-494a-a41e-181d2283ae8b
# ╠═b8ad35dc-7d12-4ef7-a680-832b255469f5
# ╠═ed293f20-0a47-45b9-a9f8-38c88ada175f
# ╟─9e9d9601-dd43-4346-a07e-4a00c74a2663
# ╠═9f663e38-8514-45b1-b7a2-b03400487565
# ╟─480bff80-55c3-411e-b829-8fa2b95550f0
# ╟─0be370e9-a71e-4d7d-b16e-0c100364c60b
# ╟─fd59de14-1c77-4572-a575-d82e1865c87d
# ╠═256b14b6-e70a-412b-9bc9-323afc35cb3c
# ╟─65b459ac-6ae2-4706-a60d-7c01211b1cf4
# ╟─3066d261-b31c-4965-9447-0ac0f36a086b
# ╟─6d02bbef-c2c7-44ee-82a9-5b64b5caca81
# ╟─3e3d3cd0-061f-4611-8d88-39514f1bc3d5
# ╟─c5684c71-ec5c-48d3-b202-6169f159d190
# ╟─9e9116f8-58be-44f2-b3e7-58d91e28d276
# ╠═0b4348fc-52d3-4006-bca5-bab0bce8d5bd
# ╠═437645da-2a7c-4cce-bd09-9e8d6ea08f88
# ╟─699bf2c2-7fa2-4027-bf05-a93900650dc6
# ╠═48f09c8f-5663-4f5f-8926-112487a4e043
# ╟─36399c3f-fc40-44b5-8ff2-e9f6b042be3e
# ╟─4e0afdaa-9284-4e29-89fa-2b82ffb1c0fd
# ╟─6eb36c84-cec3-4751-9550-aaf097425eb8
# ╠═0ec89d1f-f5d1-4d28-9002-9b2d8d47e189
# ╠═0a5faf2a-c1ea-43a6-9f84-9255cc39af27
# ╠═4a04ad4a-7502-4844-b7aa-46518190f811
# ╠═cada7a76-ad50-4b3b-8621-74bc266b7d5a
# ╠═4e54f501-16ea-49aa-a7c2-a969ed5fdd0b
# ╠═10794927-d724-4bd4-a7f8-ffca4ab18f5a
# ╠═8a324c9d-b17e-4d89-b2d3-b349b7e6b10f
# ╠═b87eafa8-39f0-4d6f-9481-7162df53b318
# ╠═83e41c0c-acf2-45d5-a326-1f36101cdc96
# ╠═5a6a8358-6e01-40a0-919e-5f12943a0593
# ╟─877057b1-0f02-48f7-8d1b-8a673d4a6b64
# ╠═44e2efab-0cc7-4731-9593-7243af2e6f5f
# ╠═26adff27-79d6-4f86-b4e9-28189cb2af97
# ╠═36aa43fe-5842-417a-a5e9-fc921116edd4
# ╠═ccdeb060-cc6d-4c71-92e5-4fe823233293
# ╠═84f8a000-073d-43d0-a934-792d48e59426
# ╠═1cedb9fd-048f-40af-81ea-174967026195
# ╠═07d09ff2-c913-4e57-9d04-34de08f31603
# ╠═4a6364de-ea9d-4fec-a6a7-a8c9b842d66b
