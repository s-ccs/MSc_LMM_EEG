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

# ╔═╡ 40de57fc-60da-11ed-2f3e-03255ba2a78d
using Pkg; Pkg.activate("/Users/luis/test")

# ╔═╡ 5894efb6-e813-4067-9e0a-04f9a73861d9
using DrWatson

# ╔═╡ 502262c6-deef-463d-869f-5fabe50f285d
using CairoMakie

# ╔═╡ 1484a682-7522-40d0-bb31-8c3156e1455b
using LaTeXStrings

# ╔═╡ 1d8d3ceb-4487-40b5-8643-714fbbce8b7c
using PlutoUI

# ╔═╡ de944e15-7d4d-4354-93df-fac59656d036
using TopoPlots

# ╔═╡ 00b97abc-0e49-4e42-a4d0-ecb60c8d9dbe
using Colors

# ╔═╡ 5d65b38b-e0a2-4e35-9fd0-ed0aac80b8f0
using ColorSchemes

# ╔═╡ 9067f3fe-0d48-4149-bd85-2a7b7d659c1a
using DelimitedFiles

# ╔═╡ 5d28682a-5283-4b6c-9df5-2a619c9b2e96
CairoMakie.activate!()

# ╔═╡ b879cd68-98d7-4289-9c2b-dcafde2014b0
begin
	theme = Theme(fontsize = 30)
	set_theme!(theme)
end

# ╔═╡ d76222ef-dd65-42f2-a7cf-00f03ccb3483
@bind t PlutoUI.Slider(1:20, show_value=true)

# ╔═╡ e3c32dd6-59f1-4bae-8d62-b304a79a7889
let
	2:2:10
	[2,4,6,8,10]
	[1,2,3,4,5]

	=> x / 2

	2:4:10
	[2,6,10]
	[1,2,3]
	[0,1,2]
	=> x ÷ 4 + 1

	4:4:10
	[4,8,12]
	[1,2,3]
	[1,2,3]
	=> x ÷ 4 + 0

	8:4:10
	[8,12]
	[1,2]
	[2,3]
	=> x ÷ 4 - 1

	9:4:10
	[9,13]
	[1,2]
	[2,3]
	=> x ÷ 4 - 1

	3:2:11
	[3,5,7,9,11]
	[1,2,3,4,5]
	x ÷ 2

	3:4:19
	[3,7,11,15,19]
	[1,2,3,4,5,6]

# ╔═╡ 67601166-8e19-40c9-889d-738958b078af


# ╔═╡ 5686713a-46be-420c-8194-5c71e6d85938
(4 - 2) 

# ╔═╡ 74c247c7-6a99-4e57-a2b0-fb30aebc32d8
let
	a = 4:3:10
	d = ((minimum(a) .% step(a)) ÷ minimum(a)) + ((step(a) - minimum(a)) ÷ step(a))
	collect(a) .÷ step(a) .+ d
end

# ╔═╡ a1ec9595-ef7b-4fd3-b9a1-1699e42d0b1d
(2 % 4) ÷ 2

# ╔═╡ 98b60bea-eb4f-4a28-8a8f-8c46e30bef7b
(8 % 4) ÷ 8

# ╔═╡ ec58fa42-6438-436d-92d5-827c85d50c86


# ╔═╡ be8e0734-86ca-44aa-ae7b-cd61372316ab
begin
	a = [3,7,11,15,19]
	a .÷ 4 .+ 1
	2 % 4 ÷ 2
end

# ╔═╡ 490ad889-0cb5-4dce-b164-f77bf3458fd9


# ╔═╡ ae4a4e5e-1429-4af7-bdad-7b33d05c8b12
8÷2

# ╔═╡ bf6f8348-79ac-44b2-8a1e-96010f5bec55
let 
	a = 12:4:20
	arr = collect(a)
	if minimum(a) > step(a)
		arr = arr .÷ step(a) #.+ (minimum(a) .% step(a) / minimum(a))
	else
		arr = arr .÷ step(a) .+ (minimum(a) .% (step(a) / minimum(a)))
	end
	collect(a), arr
end

# ╔═╡ dfbd367a-24e6-4f36-96b1-4bf140ee2f43
let
	n = 3:4:10
	m = vcat(1:length(n))	

	d = 1#Int(floor(minimum(n) / step(n)))

	m = hcat(zeros(1,d), m')

	@show minimum(n), maximum(n), length(n)
	l = LinRange(minimum(n), maximum(n), length(n))
	l = Int.([0.0; l])

	for i in l
		#xi = Int(i + 1) # stepsize 1

		d = ((minimum(n) .% step(n)) ÷ minimum(n)) + ((step(n) - minimum(n)) ÷ step(n))
		
		xi = i ÷ step(n) + d
		xi = (i == 0 ? 1 : xi + 1)
		
		@show i, xi
	end
	m
	l
	
end

# ╔═╡ 070bedd9-911a-427d-959c-cbf3af7f12da
 ÷ 4 

# ╔═╡ 0bf3b322-9154-40e8-ac22-ee808c403ea8


# ╔═╡ 15370505-92ed-464d-a3b9-9fb8346deeb2
let
	nsubj = 3:2:21
	nitem = 2:2:21
	
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
		subtitle = "β = (2.0. 0.5)  |  σsubj = (0.5, 0.0)  |  σres = 0.0001 \n noisetype = white  |  noiselevel = 2.0  |  model = twostage",
		subtitlesize = 25.0f0,
		subtitlegap = 10,
    	titlegap = 30,
		xautolimitmargin = (0.0, 0.0),
		xminorticksvisible = true,
		xminorticks = IntervalsBetween(5),
		#xticks=0:5:15,
		xlabelpadding = 20,
		xlabelfont="TeX Gyre Heros Makie Bold",
			
		yautolimitmargin = (0.0, 0.0),
		yminorticksvisible = true,
		yminorticks = IntervalsBetween(5),
		yticks=0:5:20,
		ylabelpadding = 20,
		ylabelfont="TeX Gyre Heros Makie Bold"
	)
	xlims!(0,maximum(nsubj))
	ylims!(0,maximum(nitem))

	
	dxs = 0#Int(floor(minimum(nsubj) / step(nsubj)))
	xs = LinRange((minimum(nsubj)), maximum(nsubj), length(nsubj))
	xs = [0.0; collect(xs)]

	
	dys = 0#Int(floor(minimum(nitem) / step(nitem)))
	ys = LinRange((minimum(nitem)), maximum(nitem), length(nitem))
	ys = [0.0; collect(ys)]
	
	
	zs = 
[0.0    0.0    0.0    0.0    0.0    0.0    0.0    0.0    0.0    0.0;
 12.6   17.7   21.7   25.4   28.3   31.2   30.2   36.8   38.2   38.3;
 29.3   47.4   60.6   70.4   80.5   85.3   88.8   91.6   93.5   94.7;
 51.9   75.7   89.6   95.2   98.4   98.6   99.7  100.0   99.8   99.9;
 67.8   90.9   97.9   99.9   99.7  100.0  100.0  100.0  100.0  100.0;
 81.8   96.8   99.7  100.0  100.0  100.0  100.0  100.0  100.0  100.0;
 89.1   99.4   99.9  100.0  100.0  100.0  100.0  100.0  100.0  100.0;
 93.6  100.0  100.0  100.0  100.0  100.0  100.0  100.0  100.0  100.0;
 97.0  100.0  100.0  100.0  100.0  100.0  100.0  100.0  100.0  100.0;
 98.5  100.0  100.0  100.0  100.0  100.0  100.0  100.0  100.0  100.0]

	

	#zs = round.(Int, zs)

	zs = vcat(zeros(size(zs)[2], 1)', zs)
	zs = hcat(zeros(size(zs)[1], 1), zs)

	zs = zs

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
	
	contour!(f[1,1], xs, ys, zs, 
		levels=[10,20,30,40,50,60,70,80,90,99],
		color=c,
		linewidth = 2,
		alpha=1,
		transparency = true,
	)

	c2 = repeat([(c[8], 0)], 10)
	c2[8] = (c[8], 1)
	contour!(f[1,1], xs, ys, zs, 
		levels=[10,20,30,40,50,60,70,80,90,99],
		color=c2,
		linewidth = 8,
		alpha=1,
		transparency = true,
	)

	points = [collect(Iterators.product(round.(Int, collect(xs)), round.(Int, collect(ys))))...]
	
	scatter!(f[1,1],points, marker=:xcross, color=:red)
	@show size(zs), size(xs), size(ys)
	for (x,y) in points
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
		
		@show (x,y), (xi, yi)
		
		text!(f[1,1], string.(zs[xi,yi]), position=(x,y), space = :data, align=(:center, :center))
	end
	

	Legend(f[1, 2], l, " " .* string.((1:length(l)).*10).* " %", "Power")
	
	f

end

# ╔═╡ 362574c6-3948-4d26-b20b-4176b458fbfc
RGBA{Float32}[]

# ╔═╡ 29f2e594-06bd-4ece-bb93-73566cea2b9a
[0; collect(LinRange(1,2,2))]

# ╔═╡ d995d189-be32-4059-9d71-7496641132e2
all((10, 20) .<= size(ones(10,23)))

# ╔═╡ cd61c8d2-351e-4c6e-994e-2fd5486bd8e7
 m = [0.0    0.0    0.0    0.0    0.0    0.0    0.0    0.0    0.0    0.0;
 12.6   17.7   21.7   25.4   28.3   31.2   30.2   36.8   38.2   38.3;
 29.3   47.4   60.6   70.4   80.5   85.3   88.8   91.6   93.5   94.7;
 51.9   75.7   89.6   95.2   98.4   98.6   99.7  100.0   99.8   99.9;
 67.8   90.9   97.9   99.9   99.7  100.0  100.0  100.0  100.0  100.0;
 81.8   96.8   99.7  100.0  100.0  100.0  100.0  100.0  100.0  100.0;
 89.1   99.4   99.9  100.0  100.0  100.0  100.0  100.0  100.0  100.0;
 93.6  100.0  100.0  100.0  100.0  100.0  100.0  100.0  100.0  100.0;
 97.0  100.0  100.0  100.0  100.0  100.0  100.0  100.0  100.0  100.0;
 98.5  100.0  100.0  100.0  100.0  100.0  100.0  100.0  100.0  100.0]

# ╔═╡ 42365cbb-d29c-4295-ad3a-53c968287732
begin
	x = 92.3
	floor(x / 10) * 10
end

# ╔═╡ 4e9b2c98-4040-4613-b2eb-0f2f5b2ce421
let
	f = Figure(
		backgroundcolor = :white,
		resolution = (1000, 1000),
		figure_padding = 20
	)

	Axis(
		f[1, 1],
	)

	zs = hcat(1:11) * hcat(1:11)'
	#zs[10,10] = 90
	xs = LinRange(1, 11, 11)
	ys = LinRange(1, 11, 11)

	c = collect(reverse(cgrad(:Blues, 11)))[1:11];

	contour!(f[1,1], xs, ys, zs, 
		levels=[0,10,20,30,40,50,60,70,80,90,100],
		colormap=c,
		linewidth = 2,
		alpha=1,
		transparency = true
	)

	c2 = repeat([(c[8], 0)], 10)
	#c2[8] = (c[8], 1)
	
	contour!(f[1,1], xs, ys, zs, 
		levels=[0,10,20,30,40,50,60,70,80,90,100],
		colormap=c2,
		linewidth = 8,
		alpha=1,
		transparency = true,
	)
	
points = [collect(Iterators.product(round.(Int, collect(xs)), round.(Int, collect(ys))))...]
	
scatter!(f[1,1],points)
	
for (x,y) in points
	text!(f[1,1], string.(zs[x,y]), position=(x,y), space = :data)
end
f
end

# ╔═╡ fffc6e04-99f8-456a-8d26-de0fcde06bd1
let
	f = Figure(
		backgroundcolor = :white,
		resolution = (1000, 1000),
		figure_padding = 20
	)

	Axis(
		f[1, 1],
	)

	zs = hcat(1:11).*ones(11,11)*10 .+ hcat(1:11)'
	zs[zs.>=100] .= 91
	xs = LinRange(1, 11, 11)
	ys = LinRange(1, 11, 11)

	c = collect(reverse(cgrad(:Blues, 11)))[1:11];

	contour!(f[1,1], xs, ys, zs, 
		levels=0:10:100,
		colormap=c,
		linewidth = 2,
		alpha=1,
		transparency = true
	)
points = [collect(Iterators.product(round.(Int, collect(xs)), round.(Int, collect(ys))))...]
	
scatter!(f[1,1],points)
	
for (x,y) in points
	text!(f[1,1], string.(zs[x,y]), position=(x,y), space = :data)
end
@show zs, zs[1,10]
f
zs
end

# ╔═╡ 43a90e5d-2c48-443b-94d6-1b1e0bb0c3d4
hcat(1:10).*ones(10,10)*10 .+ hcat(0:9)'

# ╔═╡ 5a11f228-df4f-4ab6-b709-e082c6dcadb7
Int.([collect(Iterators.product(collect(xs), collect(ys)))...])

# ╔═╡ 143b56f6-8cd0-4f7a-932a-900455dac56b
round.(Int, collect(xs))

# ╔═╡ 7fd45feb-38d7-4177-80b8-3f1716a1944c
let
	d=readdlm("/Users/luis/Desktop/data/power/model=twostage_nitems=2:2:50_noiselevel=2.0_noisetype=white_nsubjs=3:1:50_β=[2.0, 0.5]_σranef=(:subj => [0.0 0.0; 0.0 0.5])_σres=0.0001.csv", ',', Float64, '\n')
	
	nsubj = 3:1:50
	nitem = 2:2:50
	nsubj = 3:1:50
	nitem = 2:2:50
	
	dxs = Int(minimum(nsubj) / step(nsubj))
	dys = Int(minimum(nitem) / step(nitem))
	m = zeros(length(nsubj)+dxs,  length(nitem)+dys)
	m[dxs+1:end, dys+1:end] = d
	
	c = collect(reverse(cgrad(:Blues, 10)))[1:10];
	c = [(ci,1) for ci in c]

	subtitle = "Subtitle"

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


	xs = LinRange(0, maximum(nsubj), length(nsubj) + dxs)
		ys = LinRange(0, maximum(nitem), length(nitem) + dys)
	zs = m

	#heatmap!(f[1,1],xs, ys, zs, alpha=0.05, colormap=cgrad(:Blues, 20, rev=false)[10:2:end])
	
	contour!(f[1,1], xs, ys, zs, 
		levels=[10,20,30,40,50,60,70,80,90,99],
		color=c,
		linewidth = 2,
		alpha=1,
		transparency = true,
	)
	f
	
end

# ╔═╡ 844381ed-508f-4b41-9b98-d97f3aeb6809
d1 = readdlm("/Users/luis/Desktop/exampledata/power/model=lmm_nitems=2:2:50_noiselevel=2.0_noisetype=white_nsubjs=3:1:50_β=[2.0, 0.4]_σranef=(:subj => [0.0 0.0; 0.0 0.0])_σres=0.0001.csv", ',', Float64, '\n')

# ╔═╡ 8662712d-a912-4420-998f-6a1d9bfa53c7
reverse(d1)[40,:]

# ╔═╡ 7255eb4f-7884-4666-a8b1-bebdf48ee356


# ╔═╡ 630dc857-db4f-4ac6-810b-ea86b06f14d2
readdir("/Users/luis/Desktop/data/power")

# ╔═╡ fe071937-205d-4d32-b516-3f31fc295dea


# ╔═╡ 7ce6a87e-9095-4043-862d-b644027d675f
p =parse_savename("/Users/luis/Desktop/exampledata/power/model=lmm_nitems=2:2:50_noiselevel=2.0_noisetype=white_nsubjs=3:1:50_β=[2.0, 0.4]_σranef=(:subj => [0.0 0.0; 0.0 0.0])_σres=0.0001.csv")

# ╔═╡ e90b384a-83c4-4a6b-b08c-7a5d2af531b6
begin
	function parse_range(range_str)
		split_str = (parse.(Int, split(range_str, ":"))...,)
		return (length(split_str) == 2) ? (split_str[1]:split_str[2]) : (split_str[1]:split_str[2]:split_str[3])
	end
end

# ╔═╡ 0212e0b6-2e9d-4efd-923e-a889d7ba6a84
replace("luis.csv", ".csv"=>".png")

# ╔═╡ 3e22b6b0-3722-48ea-89ab-fce28364505a
readdir("/Users/luis/Desktop/data/power", join=true)[1]

# ╔═╡ f74b0c7e-1fe7-4fb7-a8af-322b69586533
#mkpath("/Users/luis/Desktop/data/"*"topoplots")

# ╔═╡ fd25882e-5920-431f-813e-4471dfad7c78
datadir("plots", "res")

# ╔═╡ 0b2b1545-2e63-4643-871b-a9021af20674
A = [1.0 2.0; 3 4]

# ╔═╡ d5ab3335-5858-4427-a6b4-dcf9887162bd
B = rand(10, 10)

# ╔═╡ 907b7d9f-0138-479d-b038-0b9c68226f42


# ╔═╡ 693b76ed-8058-41f5-b738-8a4f87ed2bec
A[begin,:]

# ╔═╡ 567a1e9d-b760-46af-8969-86a9cf0823a4
vcat(A[1,:]',A)

# ╔═╡ 27a8bb39-c702-4f21-a8ce-d19de4008a77
hcat(A[:,begin],A)

# ╔═╡ ed3991db-6f36-44fb-be26-c8a1085492e3
hcat(A,A[:,end])

# ╔═╡ 3903eeab-627c-41d3-83eb-07a1386c9045
vcat(A,A[end, :]')

# ╔═╡ c77f8abe-be12-4677-beb9-f1df0afda361
A

# ╔═╡ 36decfc3-259b-4399-a270-f86661076cd9
function enlarge(A;n=1)
	for i in 1:n
		#A = hcat(A[:,begin],A)
		A = hcat(A,A[:,end])
		#A = vcat(A,A[end, :]')
	end
	for i in 2:2:n
		A = vcat(A[begin,:]',A)
	end
	return A
end

# ╔═╡ 10dfd883-d8c6-4afb-b671-900393ec2b7a
let
	files = readdir("/Users/luis/Desktop/data/power", join=true)
	figs = []
	#@show files[1]
	for file in files
		!endswith(file, ".csv") && continue
		d=readdlm(file, ',', Float64, '\n')
	
		p = parse_savename(file)
		params_str = p[2]
		
		nsubj = parse_range(params_str["nsubjs"])
		nitem = parse_range(params_str["nitems"])
		
		f = Figure(
			backgroundcolor = :white,
			resolution = (1000, 1000),
			figure_padding = 20
		)
	
		@unpack β, σranef, σres, noisetype, noiselevel, model = params_str
        s1 = savename(@dict β σranef σres; connector="   |   ", equals=" = ", 
			sort=true, digits=5)
        s2 = savename(@dict noisetype noiselevel model; connector="   |   ", 
			equals=" = ", sort=true, digits=5)
        subtitle = s1 * " \n " * s2
		
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
		
		
		nsubj = 3:1:50
		nitem = 2:2:50
		
		dxs = Int(minimum(nsubj) / step(nsubj))
		dys = Int(minimum(nitem) / step(nitem))
		m = zeros(length(nsubj)+dxs,  length(nitem)+dys)
		m[dxs+1:end, dys+1:end] = d
	
		e = 2
		xs = LinRange(0, maximum(nsubj)+e÷2, length(nsubj) + dxs + e÷2)
		ys = LinRange(0, maximum(nitem)+2*e, length(nitem) + dys+e)
		
		points = [Point(x, y) for x in xs, y in ys]
		m
	
		interpolation=SplineInterpolator(;kx=4, ky=4, smoothing=40020)
		#interpolation=DelaunayMesh()
		#interpolation=ClaughTochter(fill_value=NaN, tol=1, maxiter=1, rescale=false)
		#interpolation=NullInterpolator()
	
		#m = round.(m, digits=0)
		m = enlarge(m;n=e)
	
		topoplot!(f[1,1], vec(m), vec(points);
			interpolation=interpolation,
			colormap=((cgrad(:Blues,20)[10:end])),
				contours=(
					color=:white, 
					linewidth=2, 
					levels=[10,20,30,40,50,60,70,80,90,99]
				), 
			#label_scatter=true, 
			bounding_geometry=Rect,
			enlarge=1.0,
			label_scatter=false
				
		)
	
		if false
			contour!(f[1,1], xs, ys, m, 
				levels=[10,20,30,40,50,60,70,80,90,99],
				color=:black,
				linewidth = 2,
				alpha=1,
				transparency = true,
			)
		end
	
	
		points = [collect(Iterators.product(round.(Int, collect(xs)), round.(Int, collect(ys))))...]
	
		m = round.(m, digits=2)
		
		#scatter!(f[1,1],points)
	
		for (x,y) in points
			x % 2 ==0 && continue 
			#iseven(y) && continue 
			#x !=0 && continue
			yi = Int(y/2 + 1)
			xi = x + 1
			#@show x, y, xi, yi
			#text!(f[1,1], string.(m[xi,yi]), position=(x,y), space = :data, textsize=10)
		end
		
		#path = mkpath("/Users/luis/Desktop/data/"*"topoplots/")
		#fname = replace(file, ".csv"=>".png", p[1]=>"")
		#save(path*"/"*fname, f)
	end
end

# ╔═╡ 4a3f50c2-caad-43bc-aaa5-a705616e6bf7
let
	files = readdir("/Users/luis/Desktop/data/power", join=true)
	file = files[30]
	d=readdlm(file, ',', Float64, '\n')
	
		p = parse_savename(file)
		params_str = p[2]
		
		nsubj = parse_range(params_str["nsubjs"])
		nitem = parse_range(params_str["nitems"])
		
		f = Figure(
			backgroundcolor = :white,
			resolution = (1000, 1000),
			figure_padding = 20
		)
	
		@unpack β, σranef, σres, noisetype, noiselevel, model = params_str
        s1 = savename(@dict β σranef σres; connector="   |   ", equals=" = ", 
			sort=true, digits=5)
        s2 = savename(@dict noisetype noiselevel model; connector="   |   ", 
			equals=" = ", sort=true, digits=5)
        subtitle = s1 * " \n " * s2
		
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
		
		
		nsubj = 3:1:50
		nitem = 2:2:50

		#test
		#nsubj = 3:2:50
		#nitem = 2:4:50
		
		@show minimum(nsubj), step(nsubj)
		dxs = Int(minimum(nsubj) ÷ step(nsubj))
		dys = Int(minimum(nitem) ÷ step(nitem))
		m = zeros(length(nsubj)+dxs,  length(nitem)+dys)
		#m[dxs+1:end, dys+1:end] = d
		#m[dxs+1:end, dys+1:end] = d[begin:2:end, begin:2:end] # test
	
		e = 2
		xs = LinRange(0, maximum(nsubj)+e÷2, length(nsubj) + dxs + e÷2)
		ys = LinRange(0, maximum(nitem)+2*e, length(nitem) + dys+e)
		
		points = [Point(x, y) for x in xs, y in ys]
		m
	
		interpolation=SplineInterpolator(;kx=4, ky=4, smoothing=1000)
		#interpolation=DelaunayMesh()
		#interpolation=ClaughTochter(fill_value=NaN, tol=1, maxiter=1, rescale=false)
		#interpolation=NullInterpolator()
	
		#m = round.(m, digits=0)
		m = enlarge(m;n=e)
	
		topoplot!(f[1,1], vec(m), vec(points);
			interpolation=interpolation,
			colormap=((cgrad(:Blues,20)[10:end])),
				contours=(
					color=:white, 
					linewidth=2, 
					levels=[10,20,30,40,50,60,70,80,90,99]
				), 
			#label_scatter=true, 
			bounding_geometry=Rect,
			enlarge=1.0,
			label_scatter=false
				
		)
	
		if false
			contour!(f[1,1], xs, ys, m, 
				levels=[10,20,30,40,50,60,70,80,90,99],
				color=:black,
				linewidth = 2,
				alpha=1,
				transparency = true,
			)
		end
	
	
		points = [collect(Iterators.product(round.(Int, collect(xs)), round.(Int, collect(ys))))...]
	
		m = round.(m, digits=2)
		
		#scatter!(f[1,1],points)
	
		for (x,y) in points
			x % 2 ==0 && continue 
			#iseven(y) && continue 
			#x !=0 && continue
			yi = Int(y/2 + 1)
			xi = x + 1
			#@show x, y, xi, yi
			text!(f[1,1], string.(m[xi,yi]), position=(x,y), space = :data, textsize=10)
		end
	f
end

# ╔═╡ 99eefcd4-92c9-4669-8a7a-710c171acc5b
enlarge(A,n=5)

# ╔═╡ 75046b17-d85e-4d54-9a47-9545f057237c
let
	nsubj = 3:1:50
	nitem = 2:2:50
	
	dxs = Int(minimum(nsubj) / step(nsubj))
	dys = Int(minimum(nitem) / step(nitem))
	m = zeros(length(nsubj)+dxs,  length(nitem)+dys)
	#m[dxs+1:end, dys+1:end] = d

	e = 6
	xs = LinRange(0, maximum(nsubj)+e÷2, length(nsubj) + dxs + e÷2)
	ys = LinRange(0, maximum(nitem)+2*e, length(nitem) + dys+e)

	m=enlarge(m,n=e)

	#xs = LinRange(0, maximum(nsubj), length(nsubj) + dxs)
	#ys = LinRange(0, maximum(nitem), length(nitem) + dys)

	xs,ys, m
end

# ╔═╡ c6e2b994-bfbf-4bfd-ab89-d6136accb460
let
	d=readdlm("/Users/luis/Desktop/data/power/model=twostage_nitems=2:2:50_noiselevel=2.0_noisetype=white_nsubjs=3:1:50_β=[2.0, 0.5]_σranef=(:subj => [0.0 0.0; 0.0 0.5])_σres=0.0001.csv", ',', Float64, '\n')
	d
end

# ╔═╡ 52522ae9-1db3-42b2-8507-d7293468a20e
@recipe(EEG_TopoPlot, data, labels) do scene
    return Attributes(;
        head = (color=:black, linewidth=3),
        positions = Makie.automatic,
        # overwrite some topoplot defaults
        default_theme(scene, TopoPlot)...,
        label_scatter = true,
        contours = true,
    )
end

# ╔═╡ d689ccd7-6d6f-40bf-b1e7-93d20c050860
d

# ╔═╡ c4a9dddc-ac95-4907-9586-9eea94fa953a

[Point(x,y) for ((x,y),) in Iterators.product(nsubj, nitem)...]

# ╔═╡ 449e5acc-c0d0-44be-a6f2-325365a789d0
topoplot(rand(10), (rand(Point2f, 10)); contours=(color=:white, linewidth=2), label_scatter=true, bounding_geometry=Rect)

# ╔═╡ 6a0b9926-14b0-4611-91fa-cd121b60a9b4


# ╔═╡ Cell order:
# ╠═40de57fc-60da-11ed-2f3e-03255ba2a78d
# ╠═502262c6-deef-463d-869f-5fabe50f285d
# ╠═5d28682a-5283-4b6c-9df5-2a619c9b2e96
# ╠═b879cd68-98d7-4289-9c2b-dcafde2014b0
# ╠═1484a682-7522-40d0-bb31-8c3156e1455b
# ╠═1d8d3ceb-4487-40b5-8643-714fbbce8b7c
# ╟─d76222ef-dd65-42f2-a7cf-00f03ccb3483
# ╠═e3c32dd6-59f1-4bae-8d62-b304a79a7889
# ╠═67601166-8e19-40c9-889d-738958b078af
# ╠═5686713a-46be-420c-8194-5c71e6d85938
# ╠═74c247c7-6a99-4e57-a2b0-fb30aebc32d8
# ╠═a1ec9595-ef7b-4fd3-b9a1-1699e42d0b1d
# ╠═98b60bea-eb4f-4a28-8a8f-8c46e30bef7b
# ╠═ec58fa42-6438-436d-92d5-827c85d50c86
# ╠═be8e0734-86ca-44aa-ae7b-cd61372316ab
# ╠═490ad889-0cb5-4dce-b164-f77bf3458fd9
# ╠═ae4a4e5e-1429-4af7-bdad-7b33d05c8b12
# ╠═bf6f8348-79ac-44b2-8a1e-96010f5bec55
# ╠═dfbd367a-24e6-4f36-96b1-4bf140ee2f43
# ╠═070bedd9-911a-427d-959c-cbf3af7f12da
# ╠═0bf3b322-9154-40e8-ac22-ee808c403ea8
# ╠═15370505-92ed-464d-a3b9-9fb8346deeb2
# ╠═de944e15-7d4d-4354-93df-fac59656d036
# ╠═362574c6-3948-4d26-b20b-4176b458fbfc
# ╠═29f2e594-06bd-4ece-bb93-73566cea2b9a
# ╠═d995d189-be32-4059-9d71-7496641132e2
# ╠═00b97abc-0e49-4e42-a4d0-ecb60c8d9dbe
# ╠═5d65b38b-e0a2-4e35-9fd0-ed0aac80b8f0
# ╠═cd61c8d2-351e-4c6e-994e-2fd5486bd8e7
# ╠═42365cbb-d29c-4295-ad3a-53c968287732
# ╠═4e9b2c98-4040-4613-b2eb-0f2f5b2ce421
# ╠═fffc6e04-99f8-456a-8d26-de0fcde06bd1
# ╠═43a90e5d-2c48-443b-94d6-1b1e0bb0c3d4
# ╠═5a11f228-df4f-4ab6-b709-e082c6dcadb7
# ╠═143b56f6-8cd0-4f7a-932a-900455dac56b
# ╠═9067f3fe-0d48-4149-bd85-2a7b7d659c1a
# ╠═7fd45feb-38d7-4177-80b8-3f1716a1944c
# ╠═844381ed-508f-4b41-9b98-d97f3aeb6809
# ╠═8662712d-a912-4420-998f-6a1d9bfa53c7
# ╠═7255eb4f-7884-4666-a8b1-bebdf48ee356
# ╠═630dc857-db4f-4ac6-810b-ea86b06f14d2
# ╠═5894efb6-e813-4067-9e0a-04f9a73861d9
# ╠═fe071937-205d-4d32-b516-3f31fc295dea
# ╠═7ce6a87e-9095-4043-862d-b644027d675f
# ╠═e90b384a-83c4-4a6b-b08c-7a5d2af531b6
# ╠═0212e0b6-2e9d-4efd-923e-a889d7ba6a84
# ╠═3e22b6b0-3722-48ea-89ab-fce28364505a
# ╠═10dfd883-d8c6-4afb-b671-900393ec2b7a
# ╠═4a3f50c2-caad-43bc-aaa5-a705616e6bf7
# ╠═f74b0c7e-1fe7-4fb7-a8af-322b69586533
# ╠═fd25882e-5920-431f-813e-4471dfad7c78
# ╠═0b2b1545-2e63-4643-871b-a9021af20674
# ╠═d5ab3335-5858-4427-a6b4-dcf9887162bd
# ╠═907b7d9f-0138-479d-b038-0b9c68226f42
# ╠═693b76ed-8058-41f5-b738-8a4f87ed2bec
# ╠═567a1e9d-b760-46af-8969-86a9cf0823a4
# ╠═27a8bb39-c702-4f21-a8ce-d19de4008a77
# ╠═ed3991db-6f36-44fb-be26-c8a1085492e3
# ╠═3903eeab-627c-41d3-83eb-07a1386c9045
# ╠═c77f8abe-be12-4677-beb9-f1df0afda361
# ╠═99eefcd4-92c9-4669-8a7a-710c171acc5b
# ╠═75046b17-d85e-4d54-9a47-9545f057237c
# ╠═36decfc3-259b-4399-a270-f86661076cd9
# ╠═c6e2b994-bfbf-4bfd-ab89-d6136accb460
# ╠═52522ae9-1db3-42b2-8507-d7293468a20e
# ╠═d689ccd7-6d6f-40bf-b1e7-93d20c050860
# ╠═c4a9dddc-ac95-4907-9586-9eea94fa953a
# ╠═449e5acc-c0d0-44be-a6f2-325365a789d0
# ╠═6a0b9926-14b0-4611-91fa-cd121b60a9b4
