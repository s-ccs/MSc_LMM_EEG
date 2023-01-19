### A Pluto.jl notebook ###
# v0.19.13

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

# ╔═╡ 5ea766c4-64cb-11ed-05d5-2b890410e2f6
import Pkg

# ╔═╡ f0d9aae5-29c3-4591-9267-4fe0ca1660ca
using DrWatson

# ╔═╡ 59cbf087-0580-40ad-9539-9f81d97999dd
Pkg.activate("/Users/luis/test")

# ╔═╡ facc539c-bcc8-4ab8-96c2-6815723717be
using Random

# ╔═╡ c7f8d905-1217-47e5-bc73-c8feb8d6848b
using UnfoldSim

# ╔═╡ 7d056a7d-8944-449f-9f94-828fa8a910de
using Unfold

# ╔═╡ 56ba12cb-0429-47a3-92a7-0cf78f1552db
using MixedModels

# ╔═╡ d34032e0-e0c2-49d4-972b-ad80f474d285
using MixedModelsSim

# ╔═╡ 0dbb2d3d-374f-4f96-9d71-2302a8f01c8c
using MixedModelsPermutations

# ╔═╡ f222384b-9dbb-4811-8082-5c9feb88aede
using StableRNGs

# ╔═╡ 9b119178-b942-4c96-8010-759bc8577a94
using DataFrames

# ╔═╡ f8ad43d9-5d88-49cb-bc43-f33fc495921d
using PlutoUI

# ╔═╡ 9b9033a9-97d8-4b39-80bb-085709474fc0
using PlutoUI.ExperimentalLayout: vbox, hbox, Div

# ╔═╡ a17433e5-5d71-4cb2-a6ea-03925a7f6348
using HypertextLiteral

# ╔═╡ 580ec88d-5475-4e77-9112-b01ded669734
using Statistics

# ╔═╡ e42547d2-046d-4a48-9ffc-2963f0f70b27
using HypothesisTests

# ╔═╡ 539bb8eb-af17-4477-8773-d29e0153bf81
using LinearAlgebra

# ╔═╡ c599617f-186e-4b89-99c4-9e23d634a28e
Pkg.status()

# ╔═╡ 44f51aa1-439e-4153-b469-870a09c4d1c1
begin
	html"""
	<style>
		
		
		div.plutoui-sidebar.aside {
			position: fixed;
			right: 1rem;
			top: 10rem;
			width: min(80vw, 25%);
			padding: 10px;
			border: 3px solid rgba(0, 0, 0, 0.15);
			border-radius: 10px;
			box-shadow: 0 0 11px 0px #00000010;
			max-height: calc(100vh - 5rem - 56px);
			overflow: auto;
			z-index: 40;
			background: white;
			transition: transform 300ms cubic-bezier(0.18, 0.89, 0.45, 1.12);
			color: var(--pluto-output-color);
			background-color: var(--main-bg-color);
		}

		.second {
			top: 18rem !important;
		}

		.third {
			top: 24.5rem !important;
		}
		
		div.plutoui-sidebar.aside.hide {
			transform: translateX(calc(100% - 28px));
		}
		
		.plutoui-sidebar header {
			display: block;
			font-size: 1.5em;
			margin-top: -0.1em;
			margin-bottom: 0.4em;
			padding-bottom: 0.4em;
			margin-left: 0;
			margin-right: 0;
			font-weight: bold;
			border-bottom: 2px solid rgba(0, 0, 0, 0.15);
		}
		
		.plutoui-sidebar.aside.hide .open-sidebar, .plutoui-sidebar.aside:not(.hide) .closed-sidebar, .plutoui-sidebar:not(.aside) .closed-sidebar {
			display: none;
		}

		.sidebar-toggle {
			cursor: pointer;
		}

		div.admonition.info {
			background: rgba(60,60,60,1) !important;
			border-color: darkgrey !important
		}
		div.admonition.info .admonition-title {
			background: darkgrey !important;
		}
		
	</style>
	<script>
		document.addEventListener('click', event => {
			if (event.target.classList.contains("sidebar-toggle")) {
				document.querySelectorAll('.plutoui-sidebar').forEach(function(el) {
   					el.classList.toggle("hide");
				});
			}
		});
	</script>
	"""
end

# ╔═╡ d25f57c7-880d-490f-a70b-450d9cfe604d
md"# Playground"

# ╔═╡ a0b91da9-9ad0-411f-b784-4c4fece939b3
# ╠═╡ show_logs = false
let
	sleepstudy = MixedModels.dataset(:sleepstudy)
	subj = "S" .* string.([308:309]...)
	sleepstudy = filter(r->r.days < 2 && r.subj in subj, DataFrame(sleepstudy))	

	m1 = fit(MixedModel, @formula(reaction ~ 1 + days + zerocorr((1 + days|subj))), sleepstudy, progress=false)

	H0 = coef(m1)
	H0[2] = 0.0 # slope of days is 0

	perm = permutation(StableRNG(1), 1000, m1; β=H0, use_threads=true)

	permutationtest(perm, m1)
end

# ╔═╡ 11e64cb3-baf5-4178-9048-578800acdeb0
n_subj_slider = md"n\_subj $(@bind n_subj Slider(2:1:20, default=4, show_value=true))";

# ╔═╡ d39fd32c-bc33-40bd-b238-a9456ce2dd41


# ╔═╡ bd54b327-c1d1-4e05-be24-118522879b59
n_item_slider = md"n\_item $(@bind n_item Slider(2:2:20, default=4, show_value=true))";

# ╔═╡ 1b16ed36-9e04-4e93-9994-24d8577dd665
β1_slider = md"β1 $(@bind β1 Slider(0:0.1:2, default=1, show_value=true))";

# ╔═╡ dc7bf02c-00ab-4dc3-ac97-5b8d7b09c7d5
β2_slider = md"β2 $(@bind β2 Slider(0:0.1:2, default=1, show_value=true))";

# ╔═╡ 1690f080-70f5-4a6f-8182-d2c76343f03c
σranef1_slider = md"σranef1 $(@bind σranef1 Slider(0:0.05:1, default=0, show_value=true))";

# ╔═╡ 9cd0e2cb-aa92-450c-9a13-46fffc48afde
σranef2_slider = md"σranef2 $(@bind σranef2 Slider(0:0.05:1, default=0, show_value=true))";

# ╔═╡ d9e150a2-084d-4461-8e2a-ce59c7f42100
σres_slider = md"σres $(@bind σres Slider(0.0001:0.0001:0.001, default=0.0001, show_value=true))";

# ╔═╡ 652623ed-3f3f-4491-8394-85266c278e54
noiselevel_slider = md"noiselevel $(@bind noiselevel Slider(0.01:0.5:4, default=0.5, show_value=true))";

# ╔═╡ 6914d53f-d980-45da-8d67-75385af0f236
seed_slider = md"seed $(@bind seed Slider(1:1:20, default=1, show_value=true))";

# ╔═╡ ee3b28c6-742f-4133-b0ba-1ff2ba899c27
begin
	sidebar = Div([
		n_subj_slider,
		n_item_slider,
		md"----",
		β1_slider,
		β2_slider,
		md"----",
		σranef1_slider,
		σranef2_slider,
		md"----",
		σres_slider,
		md"----",
		noiselevel_slider,
		seed_slider
	], class="plutoui-sidebar aside first")
end

# ╔═╡ 5a36ad05-e74b-48b8-8af7-5a1fdeeeef1e
begin
	# Experiment desing
	design = ExperimentDesign(
		n_subj, # n_subj
		n_item, # n_item
		nothing, # btwn_subj
		Dict("stimType" => ["A", "B"]), # btwn_item
		nothing, # both_win
	)
	
	# define component
	p100 = Component(
		[1], # basis function
		@formula(dv ~ 1 + stimType + (1 + stimType | subj)), #formula
		Dict(:stimType => DummyCoding()), # contrast coding
		[β1, β2], # effect sizes
		Dict(:subj=>create_re(σranef1, σranef2)), #ranef 
		σres # residual variance
	)
end

# ╔═╡ 857adfff-1a6a-42ab-9e89-952c729fb527
begin
	p = []
	for i in 1:100
		# define seed
		rng = MersenneTwister(i)
	
		# simulate data
		erps = simulate_erps(rng, design, [p100]);
	
		# add noise
		erps += noiselevel * hcat(gen_noise(deepcopy(MersenneTwister(i)), WhiteNoise(), length(erps)))'
	
		# create dataframe
		data = generate(design)
		data.dv = [erps...]
	
		# define & fit model
		fm = @formula(dv ~ 1 + stimType + (1 + stimType | subj))
		fm1 = MixedModels.fit(MixedModels.MixedModel, fm, data)
	
		# H0 (slope of stimType=0 ?)
		H0 = coef(fm1)
		H0[2] = 0

		# permutation test
		perm = @time permutation(StableRNG(42), 1000, fm1; β=H0)
		pvalues = permutationtest(perm, fm1)
		pvalue = getproperty(pvalues, Symbol("stimType: B"))

		push!(p, pvalue)
	end
	length(p[p.<0.05]) / length(p) * 100
end

# ╔═╡ ee5dc7f2-3a46-45b3-96f1-65dba1e71489


# ╔═╡ 598876f2-ef07-46d7-873f-3a4f15e1e928
# ╠═╡ disabled = true
#=╠═╡
let
	p = []
	for i in 1:100
		# define seed
		rng = MersenneTwister(i)
	
		# simulate data
		erps = simulate_erps(rng, design, [p100]);
	
		# add noise
		erps += noiselevel .* hcat(gen_noise(deepcopy(MersenneTwister(i)), WhiteNoise(), length(erps)))'
	
		# create dataframe
		data = generate(design)
		data.dv = [erps...]
		
		#window = 89:89
		#avg = mean(data_epoch[:, window, :], dims=2)
		#evts.dv = [avg...]
		
		gd = groupby(data, [:subj, :stimType])
		mv = combine(gd, [:dv] .=> mean)
		x = filter(:stimType => ==("A"), mv).dv_mean 
		y = filter(:stimType => ==("B"), mv).dv_mean
		push!(p, pvalue(OneSampleTTest(x, y)))
	end
	length(p[p.<0.05]) / length(p) * 100
end		
  ╠═╡ =#

# ╔═╡ 831bc9c8-42c5-45b1-8191-1efe17a3f8da
function test(p; a=1, b=2)
	return (;p, a, b)
end

# ╔═╡ bc2d501b-6388-49ba-b913-e751926124b1
begin
	a=true
	b=false

	a && not b
		
end

# ╔═╡ 855b409c-3a14-42a3-a9fd-d9491e6471bb
[1 3]

# ╔═╡ 6d159f8e-9c18-4833-b297-e4a4886a36ad
begin
	d1 = Dict("a"=>1, "b"=>2, "c"=>3)
	filter!(((k,v),) -> k in ["a", "c"], d1)
	(;d1...)
end

# ╔═╡ 4f65d90c-ded4-4e64-bd36-b134b6795eab
begin
	d = Dict(:a=>1, :b=>2)
	(;d...)
end

# ╔═╡ 151c41cc-519a-4ca8-8d9e-a34df4c7ed27
let
	d1 = Dict("a"=>1, "b"=>[1], "p"=>0.7)
	d2 = Dict("a"=>1, "b"=>1, "p"=>0.6)
	d3 = Dict("a"=>2, "b"=>2, "p"=>0.2)
	arr = [d1, d2, d3]
	nts = [NamedTuple{Tuple(Symbol.(keys(d)))}(values(d)) for d in arr]
	df = DataFrame(nts)
	gdf = collect(groupby(df, [:a, :b]))
	#gdf[1, :]
	d = Dict(pairs(copy(gdf[1][1, :])))

	map!(x->replace(string(x), string(typeof(x)) => ""), values(d))
end

# ╔═╡ ef9468cc-66e8-4ac3-beb5-7e10a2bfe62e


# ╔═╡ fdfaf8f0-34af-4fd1-ace8-fc78397fb779
# prepare parameters for logging, loading and saving

# ╔═╡ cdea6d2d-7553-467f-90c7-be744cd43f29
let
	Base.string(::WhiteNoise) = "white"
	nsubj=2; nitem=3; β=[0.0, 1.0]; 
	#σranef=Dict(:subj=>create_re(σranef1, σranef2)); σres= 0.0001
	#noisetype=WhiteNoise(); noiselevel=2.0

	
	d = @dict nsubj nitem β #σranef σres noisetype noiselevel
	d = Dict(:nsubj=>2, :nitem=>[0,0])
	v = map(x->replace(string(x), string(typeof(x)) => ""), values(d))
	v,d
end

# ╔═╡ a82e3fb2-414f-4fd6-ba0d-ae387036dd5d
(;a, b) = first(DataFrame([(a=6, b=2), (a=2, b=3)]))

# ╔═╡ 912b0b8a-d0ea-46bb-b0ad-afa1ac0bedab


# ╔═╡ 459c0461-b660-4f30-a288-cc4d54137911
begin
	nsubj = collect(2:1:10)
	nitem = collect(2:2:20)

	m = Array{Union{Float64, Missing}}(missing, 10, 10)
	m[1, :] .= 0
	
	for (subj, item) in Iterators.product(nsubj, nitem)
		m[subj, Int(item/2)] = subj*item
	end
end

# ╔═╡ 1a79799d-eade-4414-9d75-1f46352a2dd7
m

# ╔═╡ a9e95cbe-968b-4ba1-ae5c-74dee28d9984
let 
	d = DataFrame([(a=6, b=2), (a=6, b=3)])
	n = intersect(["a", "c"], names(d))
	d[!, n[1]]

	model = "pvalue_lmm"
	replace(model, "pvalue"=>"power")
end

# ╔═╡ fc48f7ad-d4d7-4e95-89b0-e7a43e7c87cf
z = DataFrame(a=[1,2,3,4], b=[1,2,3,4], c=[1,2,3,4])

# ╔═╡ 5175ecbf-c9fa-4f26-9f04-7f4248e0279c
begin
	params = Dict(pairs(copy(z[1, :])))
	#filter!(((k,v),)-> !(k in [:a, :c]), params)
	params
	Dict((string(k),v) for (k,v) in params)
end

# ╔═╡ d19d982b-c045-4d2b-bf4b-5d0a7035a1c7
Dict("b"=>2)[:a] =1

# ╔═╡ add47785-a5a0-4c8f-9706-5f988025b1ef
Symbol("a")

# ╔═╡ 379aabaa-56a5-4d4b-b986-2ef40d75415f
BLAS.get_num_threads()

# ╔═╡ 15482b7d-9e4d-42bd-9625-45ae1bf76694
let
params = Dict{String, Any}("power_twostage" => 0.0, "nitem" => 2, "nsubj" => 2, "seed" => 1, "σres" => 0.0001, "noisetype" => WhiteNoise(), "noiselevel" => 2.0, "β" => [2.0, 0.5])

d = map(x->replace(string(x), string(typeof(x)) => ""), values(params))
end

# ╔═╡ 830d7e67-5d7e-44b7-8286-e7b47637db64
let 
	params = @dict a=1 b=4 c=[1]
	map!(x->replace(string(x), string(typeof(x)) => ""), values(params))
	params
end

# ╔═╡ Cell order:
# ╠═5ea766c4-64cb-11ed-05d5-2b890410e2f6
# ╠═59cbf087-0580-40ad-9539-9f81d97999dd
# ╠═facc539c-bcc8-4ab8-96c2-6815723717be
# ╠═c7f8d905-1217-47e5-bc73-c8feb8d6848b
# ╠═7d056a7d-8944-449f-9f94-828fa8a910de
# ╠═56ba12cb-0429-47a3-92a7-0cf78f1552db
# ╠═d34032e0-e0c2-49d4-972b-ad80f474d285
# ╠═0dbb2d3d-374f-4f96-9d71-2302a8f01c8c
# ╠═f222384b-9dbb-4811-8082-5c9feb88aede
# ╠═9b119178-b942-4c96-8010-759bc8577a94
# ╠═f8ad43d9-5d88-49cb-bc43-f33fc495921d
# ╠═9b9033a9-97d8-4b39-80bb-085709474fc0
# ╠═a17433e5-5d71-4cb2-a6ea-03925a7f6348
# ╠═580ec88d-5475-4e77-9112-b01ded669734
# ╠═e42547d2-046d-4a48-9ffc-2963f0f70b27
# ╠═c599617f-186e-4b89-99c4-9e23d634a28e
# ╟─44f51aa1-439e-4153-b469-870a09c4d1c1
# ╟─ee3b28c6-742f-4133-b0ba-1ff2ba899c27
# ╟─d25f57c7-880d-490f-a70b-450d9cfe604d
# ╠═a0b91da9-9ad0-411f-b784-4c4fece939b3
# ╠═11e64cb3-baf5-4178-9048-578800acdeb0
# ╠═d39fd32c-bc33-40bd-b238-a9456ce2dd41
# ╟─bd54b327-c1d1-4e05-be24-118522879b59
# ╟─1b16ed36-9e04-4e93-9994-24d8577dd665
# ╟─dc7bf02c-00ab-4dc3-ac97-5b8d7b09c7d5
# ╟─1690f080-70f5-4a6f-8182-d2c76343f03c
# ╟─9cd0e2cb-aa92-450c-9a13-46fffc48afde
# ╟─d9e150a2-084d-4461-8e2a-ce59c7f42100
# ╟─652623ed-3f3f-4491-8394-85266c278e54
# ╠═6914d53f-d980-45da-8d67-75385af0f236
# ╠═5a36ad05-e74b-48b8-8af7-5a1fdeeeef1e
# ╠═857adfff-1a6a-42ab-9e89-952c729fb527
# ╠═ee5dc7f2-3a46-45b3-96f1-65dba1e71489
# ╠═598876f2-ef07-46d7-873f-3a4f15e1e928
# ╠═831bc9c8-42c5-45b1-8191-1efe17a3f8da
# ╠═bc2d501b-6388-49ba-b913-e751926124b1
# ╠═855b409c-3a14-42a3-a9fd-d9491e6471bb
# ╠═6d159f8e-9c18-4833-b297-e4a4886a36ad
# ╠═4f65d90c-ded4-4e64-bd36-b134b6795eab
# ╠═151c41cc-519a-4ca8-8d9e-a34df4c7ed27
# ╠═f0d9aae5-29c3-4591-9267-4fe0ca1660ca
# ╠═ef9468cc-66e8-4ac3-beb5-7e10a2bfe62e
# ╠═fdfaf8f0-34af-4fd1-ace8-fc78397fb779
# ╠═cdea6d2d-7553-467f-90c7-be744cd43f29
# ╠═a82e3fb2-414f-4fd6-ba0d-ae387036dd5d
# ╠═912b0b8a-d0ea-46bb-b0ad-afa1ac0bedab
# ╠═459c0461-b660-4f30-a288-cc4d54137911
# ╠═1a79799d-eade-4414-9d75-1f46352a2dd7
# ╠═a9e95cbe-968b-4ba1-ae5c-74dee28d9984
# ╠═fc48f7ad-d4d7-4e95-89b0-e7a43e7c87cf
# ╠═5175ecbf-c9fa-4f26-9f04-7f4248e0279c
# ╠═d19d982b-c045-4d2b-bf4b-5d0a7035a1c7
# ╠═add47785-a5a0-4c8f-9706-5f988025b1ef
# ╠═539bb8eb-af17-4477-8773-d29e0153bf81
# ╠═379aabaa-56a5-4d4b-b986-2ef40d75415f
# ╠═15482b7d-9e4d-42bd-9625-45ae1bf76694
# ╠═830d7e67-5d7e-44b7-8286-e7b47637db64
