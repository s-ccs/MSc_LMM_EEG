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

# ╔═╡ 394bcbe9-fcc8-4256-a5c2-211f34f8d34e
import Pkg

# ╔═╡ 257a5779-7d42-45a9-99cc-67449f8dc1e2
using DrWatson

# ╔═╡ d0f41050-17d1-4720-990b-15750e6a0b1f
Pkg.activate("/Users/luis/test")

# ╔═╡ 6e362118-782a-48cd-997c-0f36f4532a59
Pkg.develop(path="/Users/luis/git/UnfoldSim.jl")

# ╔═╡ 6374d2e3-366e-4ebb-a78f-18a636da2a54
begin
	using StatsModels
	using DSP
	using Random
	using PlutoUI
	using HypertextLiteral
	using PlutoUI.ExperimentalLayout: vbox, hbox, Div
	using DataFrames
end

# ╔═╡ 8bfbdf2e-ab18-4db3-9150-d2db97adfcee
using CategoricalArrays

# ╔═╡ 98870eb3-fcbc-4047-b8b9-3779aa0c695c
using UnfoldSim

# ╔═╡ b362ddf8-ca69-42db-84ec-06ddbfd9cd64
using Unfold

# ╔═╡ 76c847e0-036a-47ca-b5d2-d37440a12476
using MixedModelsPermutations

# ╔═╡ 8908f6e8-4222-4e40-9b52-ddbf2f42fb2c
using HypothesisTests

# ╔═╡ 6511d098-a2af-443b-a76a-adbee4fe1217
using StableRNGs

# ╔═╡ 8042ef7a-967f-4ade-a5e3-823e4c27c26e
using MixedModels: zerocorr

# ╔═╡ a31d8977-5dcc-4f58-955e-8933f876b880
using Statistics

# ╔═╡ 069751cf-08fd-4314-8a8c-094e82e4c80f
using LinearAlgebra

# ╔═╡ 9d2ff719-39e4-4f47-bc47-266b8b4acdd6
begin
	#using UnfoldSim
	using MixedModels: DummyCoding
	using MixedModelsSim
	using StatsPlots
end

# ╔═╡ d75bebda-80cd-485b-8c4b-c626c96ccc5c
using Plots; plotly();

# ╔═╡ 93212185-d224-40b2-a783-f80f57049828
using DelimitedFiles

# ╔═╡ 0465ef79-46fd-4461-a5c6-155775a90c86
md"#### Imports & Config "

# ╔═╡ 68a88d32-520d-4aaf-963c-3a9cea1ac2a7
#using MixedModelsSim

# ╔═╡ b18e64ab-2154-4b89-b9e6-d5f19536fb23
import CairoMakie

# ╔═╡ 2e658587-b126-4f43-84be-15f612bfa2c7
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

# ╔═╡ c7d8d28f-193e-47e3-a470-973fc134230a
n_item_slider = md"n\_item $(@bind n_item Slider(2:2:40, default=4, show_value=true))";

# ╔═╡ 0136f6d1-e765-47fc-a6ee-0024ae7515d7
n_subj_slider = md"n\_subj $(@bind n_subj Slider(2:40, default=2, show_value=true))";

# ╔═╡ 220a003e-baa9-4817-acba-c673ba6d69cc
β1_slider = md"β1 $(@bind β1 Slider(0:0.1:2, default=1, show_value=true))";

# ╔═╡ 9179f2cf-60fb-461e-8f2e-d39a9535ad83
β2_slider = md"β2 $(@bind β2 Slider(0:0.1:1, default=0.5, show_value=true))";

# ╔═╡ 86b0dbc1-771f-4388-8b7a-61690279ad25
σranef1_slider = md"σranef1 $(@bind σranef1 Slider(0:0.05:1, default=0, show_value=true))";

# ╔═╡ 1f9a1c9a-e0ad-4091-bfcb-c8051ce31c15
σranef2_slider = md"σranef2 $(@bind σranef2 Slider(0:0.05:1, default=0, show_value=true))";

# ╔═╡ 0c8b810b-c844-4cf1-8928-ae103e6e8426
σranef3_slider = md"σranef3 $(@bind σranef3 Slider(0:0.05:1, default=0, show_value=true))";

# ╔═╡ a15d90ac-5179-41d9-92c7-5094975ae794
σres_slider = md"σres $(@bind σres Slider([0.0001, 0.01, 0.1, 1.0, 10], default=0.0001, show_value=true))";

# ╔═╡ b65530c9-8545-4531-91f5-9b0dd1f963a6
noiselevel_slider = md"noiselevel $(@bind noiselevel Slider(0.01:0.5:4, default=0.5, show_value=true))";

# ╔═╡ 6f39f387-aa3a-4491-904b-bb5386460f3b
seed_slider = md"seed $(@bind seed Slider(1:1:20, default=1, show_value=true))";

# ╔═╡ 0c87a4eb-a8fa-4e07-a9e8-c003f201f34b
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
		σranef3_slider,
		md"----",
		σres_slider,
		md"----",
		noiselevel_slider,
		seed_slider
	], class="plutoui-sidebar aside first")
end

# ╔═╡ 5954ea63-afc0-4aa5-b97c-f62069d7c1af
md"# Define design & parameters"

# ╔═╡ 886d6052-6dcd-4707-ae2b-88b778c91e75
begin
	model = "lmmperm"
	startswith(model, "lmm")
end

# ╔═╡ 55f2e127-67d5-4b2e-8838-8965fb743d7f
hcat(repeat(palette(:tab10)[1:n_subj], inner=n_item))'

# ╔═╡ d012eba7-d339-4670-a575-8bd00ad922ff
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
		padarray(hanning(25), (-50, 50), 0), # basis function
		@formula(dv ~ 1 + stimType + (1 + stimType | subj) + (1 | item)), #formula
		Dict(:stimType => DummyCoding()), # contrast coding
		[β1, β2], # effect sizes
		Dict(:subj=>create_re(σranef1, σranef2), :item=>create_re(σranef3)), #ranef 
		σres # residual variance
	)
	
	# define seed
	rng = MersenneTwister(seed)

	# construct simulation 
	simulation = Simulation(
		design, # experiment design
		[p100], # components
		125, # epochlen
		305, # fixationlen
		PinkNoise(), # noisetype
		noiselevel # noiselevel
	)
end;

# ╔═╡ 25d2b408-3482-4fd6-816e-b15bab9e5269
designdata = generate(design);

# ╔═╡ 52a6ec4c-1dea-493a-b44c-22e7e3611a43
select(designdata, [:subj, :item, :stimType])

# ╔═╡ 1154e737-57b0-4f6b-9436-60d5dc9c0b4e
default(
	linewidth=2,
	legend=(:outertopright), 
	extra_plot_kwargs = KW(:legend => KW(:orientation => "v"))
)

# ╔═╡ 6256574f-b630-438a-ae85-7f1ad3e11626
md"# Simulation (1)"

# ╔═╡ 8bebd55f-905b-43be-9889-914c42744d9a
erps = simulate_erps(rng, design, [p100]);

# ╔═╡ a1a54ae3-953e-4f05-aa44-ed0e7e9dc7fa
md"# Simulation (2)";

# ╔═╡ b7272157-db87-47f5-a979-264fe32da114
begin
	df = deepcopy(designdata)
	df.dv = erps[63, :]
	@df df scatter(
		:item, :dv, 
		group=(:subj, :stimType),
		marker=[:circle :rect],
		color=hcat(repeat(1:n_subj, inner=2))',
		ylims=(0,2)
	)
end

# ╔═╡ 9a5a4a64-5c1d-4be9-bc8d-c1df9b550104
df

# ╔═╡ cdaa9594-ccd9-4687-b8dd-c3add9b616d2
l1 = designdata.subj .* designdata.item .* " (" .* designdata.stimType .* ")";

# ╔═╡ 1790d646-3ae3-41f3-9d1c-ff5e5ce0b193
# ╠═╡ show_logs = false
plot(erps, 
	title="Erps", 
	label=permutedims(hcat(l1)), 
	ls=hcat(repeat(0:5:(2-1)*5, outer=2))', 
	color=hcat(repeat(1:n_subj, inner=n_item))',
	ylims=(0,2),
	xlabel="Time (Samples)",
	ylabel="Potential (μV)"
)

# ╔═╡ f355f587-d8f8-4102-ba89-9e9f782768b4
# ╠═╡ show_logs = false
let
	p1 = plot(erps[:, 1:n_item], 
		title="Erps", 
		label=permutedims(hcat(l1[1:n_item])), 
		ls=hcat(repeat(0:5:(2-1)*5, outer=2))', 
		color=1#hcat(repeat(1:n_subj, inner=n_item))'
	)
	p2 = plot(erps[:, n_item+1:2*n_item], 
		title="Erps", 
		label=permutedims(hcat(l1[ n_item+1:2*n_item])), 
		ls=hcat(repeat(0:5:(2-1)*5, outer=2))', 
		color=2#hcat(repeat(1:n_subj, inner=n_item))'
	)
#	p3 = plot(erps[:, 2*n_item+1:3*n_item], 
#		title="Erps", 
#		label=permutedims(hcat(l1[2*n_item+1:3*n_item])), 
#		ls=hcat(repeat(0:5:(2-1)*5, outer=2))', 
#		color=3#hcat(repeat(1:n_subj, inner=n_item))'
#	)
	
	plot(p1,p2, layout = (2, 1), size=(600, 600), ylims=(0,3))
end;

# ╔═╡ c76f8e4a-a418-42b1-98f4-228f9ee7cd36
md"# Simulation (2)"

# ╔═╡ 5227462f-f1ef-43bc-9da6-3747e76860b8
# ╠═╡ show_logs = false
let
	σ_res = 0.0001

	# wilkinson formula - random effects structure
	formula = @formula dv ~ 1 + stimType + (1 + stimType | subj) + (1 | item)

	# contrasts
	contrasts = Dict(:stimType => EffectsCoding())
	
	p100 = Component(
		padarray(hanning(25), (-25, 200), 0),
		formula,
		contrasts,
		[2.0, 0.],
		Dict(:subj => create_re(0.0, 0.0), :item=>create_re(0.0)), 
		σ_res
	)

	n100 = Component(
		padarray(-hanning(50), (-30, 170), 0),
		formula,
		contrasts,
		[2.0, 0.5],
		Dict(:subj => create_re(0.0, 0.0), :item=>create_re(0.0)), 
		σ_res
	)

	p200 = Component(
		padarray(hanning(50), (-65, 135), 0),
		formula,
		contrasts,
		[2.5, -0.25],
		Dict(:subj => create_re(0.0, 0.0), :item=>create_re(0.0)), 
		σ_res
	)

	p300 = Component(
		padarray(hanning(150), (-90, 10), 0),
		formula,
		contrasts,
		[6.0, 0.1],
		Dict(:subj => create_re(0.0, 0.0), :item=>create_re(0.0)), 
		σ_res
	)

	erps = simulate_erps(rng, design, [p100, n100, p200, p300]);

	plot(erps, 
	title="Erps", 
	label=permutedims(hcat(l1)), 
	ls=hcat(repeat(0:5:(2-1)*5, outer=2))', 
	color=hcat(repeat(1:n_subj, inner=n_item))',
	xlabel="Time (Samples)",
	ylabel="Potential (μV)"
)
end

# ╔═╡ 6a95d98c-c4e4-410a-bfd2-8f0742707405
md"# Simulation (3)"

# ╔═╡ 3237acea-2f03-4d7b-9a25-bfa2c264497a
eeg, onsets = simulate(rng, simulation);

# ╔═╡ d776d731-baf9-4851-9457-ebb06aaab2d9
l2 = collect(Set(designdata.subj));

# ╔═╡ 684f5a6b-ef1e-4fd9-b1af-5a04f7c29412
let
	bf = padarray(hanning(25), (-50, 50), 0)

	f = CairoMakie.Figure(
		backgroundcolor = :white,
		resolution = (1000, 600),
		figure_padding = 20
	)

	ax = CairoMakie.Axis(
		f[1, 1],
		title = "Simulated EEG",
		titlesize = 30,
		#xlabel = "",
		#ylabel = "Power",
		#subtitle = subtitle,
		subtitlesize = 25.0f0,
		subtitlegap = 10,
		titlegap = 30,
		xautolimitmargin = (0.0, 0.0),
		xminorticksvisible = true,
		#xminorticks = IntervalsBetween(5),
		#xticks=0:5:maximum(nitem),
		xlabelpadding = 20,
		xlabelfont="TeX Gyre Heros Makie Bold",
		xlabelsize=25,

		yautolimitmargin = (0.0, 0.0),
		yminorticksvisible = true,
		#yminorticks = IntervalsBetween(10),
		#yticks=0:10:maximum(100),
		ylabelpadding = 20,
		ylabelfont="TeX Gyre Heros Makie Bold",
		ylabelsize=25
	)

	#CairoMakie.ylims!(0, 2)
	#CairoMakie.lines!(bf, linewidth=2)

	#c = repeat(palette(:tab10)[1:n_subj], inner=n_item)
	#ls = repeat([:solid, :dash], outer=n_item)
	#labels = permutedims(hcat(l1))
	#lin = []
	#@show ls
	#for (i, erp) in enumerate(eachrow(erps'))
	#	l = CairoMakie.lines!(erp, linestyle=ls[i], color=c[i], linewidth=3, label=labels[i])
	#	push!(lin, l)
	#end

	c = repeat(palette(:tab10)[1:n_subj])
	labels=reverse(permutedims(hcat(l2)))
	for (i, erp) in enumerate(eachrow(eeg'))
		l = CairoMakie.lines!(erp, color=c[i], linewidth=3, label=labels[i])
	end
	
	CairoMakie.Legend(f[1,2], ax)
	f
	#CairoMakie.save("/Users/luis/Desktop/masterthesis/plots/eeg.png", f)
end

# ╔═╡ 6da33923-0350-4b45-9bc1-03c4e44932df
plot(
	eeg, 
	title="EEG", 
	label=permutedims(hcat(l2)),
	ylim=(-3.5, 3.5),
		xlabel="Time (Samples)",
	ylabel="Potential (μV)"
)

# ╔═╡ 76b12cef-75fc-43ba-b4ee-8f8d2b107904
md"# Extract Epochs"

# ╔═╡ 9f3a5bfd-9b49-4dfe-997c-c374a744a79d
data, evts = UnfoldSim.convert(eeg, onsets, design);

# ╔═╡ 21a2f692-84ba-4159-b722-2c26f0d1f722
data_epoch, times = Unfold.epoch(data=data, tbl=evts, τ=(-0.1,1.2), sfreq=256);

# ╔═╡ fe5a6986-6edc-4245-8ace-30fbb038386e
# ╠═╡ show_logs = false
let
	c = repeat(vcat(1:n_subj), inner=n_item)
	ls = repeat([0, 5], outer=n_item*n_subj)
	p = plot(title="Epochs")
	for i in 1:size(evts, 1)
		plot!(times, data_epoch[:, :, i]', label=l1[i], c=c[i], ls=ls[i])
	end
	p
	xlabel!("Time (seconds)")
	ylabel!("Potential (μV)")
end

# ╔═╡ fc890d92-0619-4c65-8d2e-0eb48e466bfc


# ╔═╡ c62c4571-5e59-4a16-9582-e2450adba584
md"# Analysis (Two-stage) [over time]"

# ╔═╡ 5b86b8cd-7b2e-48b6-b6c1-576aa9029734
"""
Fit unfold
"""
function fit_unfold_model(evts, data, times, subj)
	# basisfunction via FIR basis
	basisfunction = firbasis(τ=(-0.1,1.2), sfreq=256, name="stimulus")
	
	# formula in wilikinson notation
	f  = @formula 0~0+condA+condB;

	# map basidfunction & formula into a dict
	bfDict = Dict(Any=>(f, times));

	# filter subjects events out
	subj_evts = filter(row -> row.subject == subj, evts)
	
	# fit model
	m = fit(UnfoldModel, bfDict, subj_evts, data);

	# create result dataframe
	results = coeftable(m);

	condA = filter(row->row.coefname=="condA", results).estimate
	condB = filter(row->row.coefname=="condB", results).estimate

	return condA, condB
end;

# ╔═╡ 99937b83-ac56-4e2f-bb80-a0dcaeacaae5
md"# Analysis (Two-stage) [average]"

# ╔═╡ 8e4ee955-35e0-4b3e-bcf5-7b3f8accf575
import MixedModels

# ╔═╡ 2a486c0d-1bd3-43a3-a9f9-c219d104bae8
begin
	window = 87:91
	avg = mean(data_epoch[:, window, :], dims=2)
	evts.dv = [avg...]
end

# ╔═╡ 7f6445da-f73a-4b25-b6cc-2495c63b8f13
Pkg.status()

# ╔═╡ 8167502c-0a08-4ae9-95ee-d1d83c91343b
begin
	gd = groupby(evts, [:subject, :cond])
	mv = combine(gd, [:dv] .=> mean)
	x = filter(:cond => ==("A"), mv).dv_mean 
	y = filter(:cond => ==("B"), mv).dv_mean
	HypothesisTests.pvalue(OneSampleTTest(x, y))
end

# ╔═╡ 2e7d5010-5705-4970-8597-6e12d491f034


# ╔═╡ 700257d5-7f56-42ae-b190-f44a85d1f212
begin
		fm = @formula(dv ~ 1 + cond + (1 +cond | subject))
		fm1 = MixedModels.fit(MixedModels.MixedModel, fm, evts)
end

# ╔═╡ fc90e723-f672-4621-a454-ede3e953c254
let
	fm = @formula(dv ~ 1 + cond + (1 + cond | subject))
	fm1 = MixedModels.MixedModel(fm, evts)
	fm1.optsum.maxtime = 1
	MixedModels.refit!(fm1)
	#fm1.pvalues[indexin(["cond: B"], MixedModels.fixefnames(fm1))[1]]
end

# ╔═╡ b35380b8-4c63-4a2f-8096-683b24f0d6e4
BLAS.get_num_threads()

# ╔═╡ a467e23c-9e06-4d6e-8c21-4eee056b1c1d
begin
	for i in 1:0
		H0 = coef(fm1) # H0 (slope of stimType=0 ?)
		H0[2] = .0
		perm = @time permutation(StableRNG(42), 1000, fm1; β=H0)
		pvalues = permutationtest(perm, fm1)
		p = getproperty(pvalues, Symbol("cond: B"))
		#propertynames(fm1)
	end
end

# ╔═╡ b0826444-99aa-44ed-8fc9-4cf9fa9db9ff


# ╔═╡ 5e54b929-0aee-4f00-a4a1-f2aa23f91034
let
	model = "A"
	N = 1:100

	function A(m, n)
		n,m
	end

	@time [A(model,n) for n in N]

end

# ╔═╡ 94a83162-58f6-47b8-b472-71a2ec80b74a
[(x,y) for (x,y) in [Iterators.product(1:2, 2:4)...]]

# ╔═╡ 508362e2-bf57-46d9-ac4a-7cf1b5e53afc
MixedModels.ranef(fm1)

# ╔═╡ 4ddff47d-d717-4f8e-bdb2-522cd2d59c27
fm1

# ╔═╡ 75f44e0b-9c00-4893-a855-1dc673d2d302
fm1.pvalues[indexin(["cond: B"], MixedModels.fixefnames(fm1))[1]]

# ╔═╡ 6c2e3ec4-cdd3-4cbb-81f0-2837284a6c9f
md"# Analysis (LMM)"

# ╔═╡ 62cf6106-a411-44eb-bbd3-1da957cb3aeb
# ╠═╡ show_logs = false
begin
	e = deepcopy(evts)
	e.subject  = categorical(Array(e.subject))
	e.stimulus  = categorical(Array(e.stimulus))
	
	# basisfunction via FIR basis
	#basisfunction = firbasis(τ=(-0.1,1.2), sfreq=256, name="stimulus")
	
	# formula in wilikinson notation
	#f = @formula 0~1+cond+(1+cond|subject) + (1|stimulus)
	#f  = @formula 0~condA+condB+(1|subject)
	f = @formula 0 ~ 0 + condA + condB + (1|subject)
	contrasts = Dict(:cond => DummyCoding())


	# map basidfunction & formula into a dict
	bfDict = Dict(Any=>(f, times));
	
	# fit model
	m = fit(UnfoldModel, bfDict, e, Base.convert(Array{Float64, 3}, data_epoch), contrasts=contrasts);

	# create result dataframe
	res = coeftable(m)
end;

# ╔═╡ 03888ee2-5f58-414e-b8f0-e8cf6280369d
begin
	condA = filter(row->row.coefname=="condA" && row.group==nothing, res).estimate
	condB = filter(row->row.coefname=="condB" && row.group==nothing, res).estimate
	intr_subj = filter(row->row.coefname=="(Intercept)" && row.group==:subject, res).estimate
	slope_subj = filter(row->row.coefname=="cond: B" && row.group==:subject, res).estimate
	intr_item = filter(row->row.coefname=="(Intercept)" && row.group==:stimulus, res).estimate
	plot(times, intr_subj, ylims=(0,2))
end;

# ╔═╡ aa26a951-00fd-485c-b15e-55455a9483f8
# ╠═╡ show_logs = false
plot(times, [condA, condB], ylims=(-0.5, 2), c=:black, ls=[0 5],
	xlabel="Time (seconds)",
	ylabel="Potential (μV)")

# ╔═╡ ed00150a-d95e-4a1f-a85a-4409366d1bf3


# ╔═╡ 84bd1e44-b998-47bb-8c7c-ee99c1f42dd4
coeftable(m);

# ╔═╡ 88a9e294-4d97-40bb-9866-ce7a0362b1b3
md"# End"

# ╔═╡ 52595862-4e17-4353-9c9a-a099aa50a69b
html"<button onclick=present()>Present</button>"

# ╔═╡ 5c8c6ed1-5b96-4464-b0e0-bf6a9b8237a4
md"# Other"

# ╔═╡ f8e7e19d-10d2-4a78-a160-1cca10f72b09
# ╠═╡ show_logs = false
let
	# parmeters
	basisfunction = [1]
	formula = @formula(dv ~ 1 + (1 | item) + (1 | subj) )
	contrasts = Dict(:stimType => DummyCoding())
	
	β = [2.0] 
	σ_ranef = Dict(:subj => create_re(0.5), :item=>create_re(0.0))
	σ_res = 0.0001
	
	btwn_subj = nothing
	btwn_item = Dict("stimType" => ["A", "B"])
	both_win = nothing
	
	# create design
	design = ExperimentDesign(5, 10, btwn_subj, btwn_item, both_win)

	# create component
	p100 = Component(basisfunction, formula, contrasts, β, σ_ranef, σ_res)

	# simulate
	t = simulate_erps(MersenneTwister(1), design, [p100])

	# for plotting 
	data = generate(design)
	data.dv .= vec(t)

	# plot
	@df data scatter(:item, :dv, group=(:subj), ylims=(0,4))
end

# ╔═╡ fb49230b-a7c0-4e0b-bbab-2eab6cf25ae8


# ╔═╡ 57f9b568-2cb0-441f-bf20-7bc39bc4dd77
B = [1 2;3 4;5 6]

# ╔═╡ 7260b5d5-65d1-411e-8b20-ab6ed6491987
B[3,2]

# ╔═╡ 59285868-6aae-467d-94ab-50e8fb949eca
function sim(nsubj, nitem, seed, params)
    # unpack parameters
    @unpack subj_btwn, item_btwn, both_win, β, σranef, σres, basis, fixationlen, formula, contrasts, noisetype, noiselevel = params

    # create random number generator
    rng = MersenneTwister(seed)

    # init design, components & simulation
    design = ExperimentDesign(nsubj, nitem, subj_btwn, item_btwn, both_win)
    component = Component(basis, formula, contrasts, β, σranef, σres)
    simulation = Simulation(design, [component], length(basis), fixationlen, noisetype, noiselevel)

    # simulate
    eeg, onsets = UnfoldSim.simulate(deepcopy(rng), simulation)
    data, evts = UnfoldSim.convert(eeg, onsets, design)

    # epoch data
    τ = (-0.1, 1.2) #QUICKFIX
    sfreq = 256 #QUICKFIX
    data_epoch, times = Unfold.epoch(data=data, tbl=evts, τ=τ, sfreq=sfreq)
    
    return data, evts, data_epoch, times
end

# ╔═╡ 28d0588b-6492-4c29-bff0-078463341c54
function pvalue((data, evts, data_epoch, times), model; quicklmm=true, timeexpanded=false)
    # average over window
    window = 89:89
    avg = mean(data_epoch[:, window, :], dims=2)
    evts.dv = [avg...]

    # two stage
    if model=="twostage" && !timeexpanded
        gd = groupby(evts, [:subject, :cond])
        mv = combine(gd, [:dv] .=> mean)
        x = filter(:cond => ==("A"), mv).dv_mean
        y = filter(:cond => ==("B"), mv).dv_mean
        pvalue = HypothesisTests.pvalue(OneSampleTTest(x, y))

    elseif model=="lmm" && !timeexpanded
        #fm = @formula(dv ~ 1 + cond + (1 + cond | subject))
        #fm1 = fit(MixedModels.MixedModel, fm, evts, progress=false)
		fm = @formula(dv ~ 1 + cond + (1 + cond | subject))
		fm1 = MixedModels.MixedModel(fm, evts)
		fm1.optsum.maxtime = 1
		MixedModels.refit!(fm1, progress=false)

        if quicklmm
            pvalue = fm1.pvalues[indexin(["cond: B"], MixedModels.fixefnames(fm1))[1]]
        
        elseif !quicklmm
            H0 = coef(fm1) # H0 (slope of stimType=0 ?)
            H0[2] = 0
            pvalue = try
                perm = permutation(StableRNG(42), 1000, fm1; β=H0, hide_progress=true)
                pvalues = permutationtest(perm, fm1)
                getproperty(pvalues, Symbol("cond: B"))
            catch e
                @warn e seed nsubj nitem β σranef σres noisetype noiselevel
                missing
            end
        end
    end

    return pvalue
end

# ╔═╡ 4d7eb10a-43c1-4686-af10-4e38fadac34e
function power(pvalues)
    return length(pvalues[pvalues.<0.05]) / length(pvalues) * 100
end

# ╔═╡ 21f7a95b-ec4e-43b2-8817-fc93f6aad0fd
let
	# params = (a=1, b=2, c=3) 
	function run(params)
		seeds = pop!(params, :seeds)
		nsubjs = pop!(params, :nsubjs)
		nitems = pop!(params, :nitems)
		models = pop!(params, :models)
		A = [[power(pvalue.(sim.(ns, ni, seeds, (params,)), model)) for ns in nsubjs, ni in nitems] for model in models]
		return A
	end
	
	function power(arr)
		return sum(arr) / length(arr)
	end
	
	function pvalue((a,b,c,d), model)
		return a+b+c+d
	end
	
	
	function sim(ns,ni,seed, p...)
		return 1,2,3,4
	end

	parameter = Dict(
		:a => [0.5, 1.0],
		:b => 1.0,
		:c => "white",
		:seeds => 1:10,
		:nsubjs => 1:1:5,
		:nitems => 2:2:4,
		:models => [["lmm", "twostage"]]
	)

	parameter_list = dict_list(parameter)
	map(run, parameter_list)
end

# ╔═╡ 4e3d164d-a57a-47d4-85e5-c8dd8395e8f3
function run_iteration(nsubj, nitem, seed, params, model)
	p = power(pvalue.(sim.(nsubj, nitem, seed, (params,)), model))
	return p
end

# ╔═╡ 15f92db3-2027-4bb9-b7df-67908745fef7
#using CairoMakie

# ╔═╡ 978ee41a-6cb5-43ae-9fdb-6ae259082f2e
let
	d1 = readdlm("/Users/luis/Desktop/exampledata/power/model=lmm_nitems=2:2:50_noiselevel=2.0_noisetype=white_nsubjs=3:1:50_β=[2.0, 0.4]_σranef=(:subj => [0.0 0.0; 0.0 0.0])_σres=0.0001.csv", ',', Float64, '\n')
	d = reverse(d1)
	nsubj = 3:1:50
	nitem = 2:2:50
	
	dxs = Int(minimum(nsubj) / step(nsubj))
	dys = Int(minimum(nitem) / step(nitem))
	m = zeros(length(nsubj)+dxs,  length(nitem)+dys)
	m[dxs+1:end, dys+1:end] = d
	
	c = collect(reverse(cgrad(:Blues, 10)))[1:10];
	c = [(ci,1) for ci in c]

	f = Figure(
		    backgroundcolor = :white,
	   	    resolution = (1000, 1000),
		    figure_padding = 20
		)

	xs = LinRange(0, maximum(nsubj), length(nsubj) + dxs)
		ys = LinRange(0, maximum(nitem), length(nitem) + dys)
	zs = m

	contour!(f[1,1], xs, ys, zs, 
		levels=[10,20,30,40,50,60,70,80,90,99],
		color=c,
		linewidth = 2,
		alpha=1,
		transparency = true,
	)
	f
end

# ╔═╡ ae52c5f4-e4cc-499f-9c39-10a894d03608
begin
	Base.string(::WhiteNoise) = "white"
	    Base.string(::RedNoise) = "red"
	    Base.string(::PinkNoise) = "pink"
end

# ╔═╡ 59dd5e1e-0289-4e6f-bca3-9d92c472030d
# ╠═╡ show_logs = false
begin
	c = repeat(vcat(1:n_subj), inner=n_item)
	ls = repeat([0, 5], outer=n_item*n_subj)
	subjects = ["S"*string(i) for i in 1:n_subj];
	evts.subject = replace.(evts.subject, "S0" => "S")

	data_epoch_subjects = []
	map(Base.Iterators.partition(axes(data_epoch,3), n_item)) do cols
	  	push!(data_epoch_subjects, data_epoch[:, :, cols])
	end

	cond_temp = fit_unfold_model.((evts,), data_epoch_subjects, (times, ), subjects)
	condA2 = [row[1][1] for row in eachrow(cond_temp)]
	condB2 = [row[1][2] for row in eachrow(cond_temp)]
	    
	# ttest & pvalue
	condA2 = hcat(condA2...)
	condB2 = hcat(condB2...)

	l3_ = sort(collect(Set(designdata.subj .* " (" .* designdata.stimType .* ")")))
	l3 = [l3_[1:2:end]..., l3_[2:2:end]...]
	
	plot(times, 
		[condA2, condB2], 
		ylims=(-0.5, 2), 
		label=permutedims(hcat(l3)), 
		ls=hcat(repeat(0:5:(2-1)*5, inner=n_subj))',
		color=hcat(repeat(1:n_subj, outer=2))',
		xlabel="Time (seconds)",
		ylabel="Potential (μV)"
	)
end

# ╔═╡ f21dcf26-9cee-48fd-83fd-96c9a2a69024
function run(params)
    # select outer loop iteration parameters
    seed = pop!(params, "seeds")
    nsubjs = pop!(params, "nsubjs")
    nitems = pop!(params, "nitems")
    models = pop!(params, "models")
    
    # create power matrix
    #A = [[power(pvalue.(sim.(nsubj, nitem, seed, (params,)), model)) for nsubj in nsubjs, nitem in nitems] for model in models]

	arr = []
	# create and save power matrices
	for model in models
		
		# compute power for specific combination
		# P = power(pvalue.(sim.(nsubj, nitem, seed, (params,)), model))
		P = map(((nsubj, nitem),)->run_iteration(nsubj, nitem, seed, params, model), reverse([Iterators.product(nsubjs, nitems)...]))

		P = reshape(reverse(P), (length(nsubjs), length(nitems)))
		
		# prepare parameters for logging, loading and saving
		@unpack β, σranef, σres, noisetype, noiselevel = params
    	d = @dict nsubjs nitems model β σranef σres noisetype noiselevel
    	map!(x->replace(string(x), string(typeof(x)) => ""), values(d))

		plot(P, nsubjs, nitems, params, model)

		# save to csv
		sname = savename(d, "csv")
		#writedlm(datadir("power", sname),  P, ',')
		push!(arr, P)
	end

   
    
    return arr
end

# ╔═╡ 4b9e2d97-d7c4-4035-9625-48c738d338de
begin
	parameter = Dict(
	    "subj_btwn" => nothing,
	    "item_btwn" => Dict("stimType" => ["A", "B"]),
	    "both_win" => nothing,
	    "basis" => [padarray(hanning(50), (-50, 50), 0)],
	    "fixationlen" => 305,
	    "formula" => @formula(dv ~ 1 + stimType + (1 + stimType | subj)),
	    "contrasts" => Dict(:stimType => EffectsCoding()),
	    "β" => [[2.0,0.5]],
	    "σranef" => [Dict(:subj => create_re([1.0, 0.0]...))],
	    "σres" => 0.0001,
	    "noisetype" => WhiteNoise(),
	    "noiselevel" => [1.0, 2.0],
	    "seeds" => 1:2,
	    "nsubjs" => 2:1:4,
	    "nitems" => 2:2:4,
	    "models" => [["twostage", "lmm"]]
	)
	
	parameter_list = dict_list(parameter)
	r = map(run, parameter_list)
	r
end

# ╔═╡ 2c0b8f9a-262e-44b0-a274-7b67d64419ac
function plot2(P, nsubj, nitem, params, model)
	 # construct subtitle
      	params["σranef"] = [last(first(params["σranef"]))[1,1], last(first(params["σranef"]))[2,2]]
		map!(x->replace(string(x), string(typeof(x)) => ""), values(params))
		@unpack β, σranef, σres, noisetype, noiselevel = params

	
        s1 = savename(@dict β σranef σres; connector="   |   ", equals=" = ", sort=true, digits=5)

	
		@show s1
		@show β σranef
end

# ╔═╡ 47fd9021-cdc2-4809-8499-55750768d3bc
r[1]

# ╔═╡ Cell order:
# ╟─0465ef79-46fd-4461-a5c6-155775a90c86
# ╠═394bcbe9-fcc8-4256-a5c2-211f34f8d34e
# ╠═d0f41050-17d1-4720-990b-15750e6a0b1f
# ╠═6374d2e3-366e-4ebb-a78f-18a636da2a54
# ╠═6e362118-782a-48cd-997c-0f36f4532a59
# ╠═d75bebda-80cd-485b-8c4b-c626c96ccc5c
# ╠═8bfbdf2e-ab18-4db3-9150-d2db97adfcee
# ╠═98870eb3-fcbc-4047-b8b9-3779aa0c695c
# ╠═b362ddf8-ca69-42db-84ec-06ddbfd9cd64
# ╠═68a88d32-520d-4aaf-963c-3a9cea1ac2a7
# ╠═76c847e0-036a-47ca-b5d2-d37440a12476
# ╠═8908f6e8-4222-4e40-9b52-ddbf2f42fb2c
# ╠═6511d098-a2af-443b-a76a-adbee4fe1217
# ╠═b18e64ab-2154-4b89-b9e6-d5f19536fb23
# ╟─2e658587-b126-4f43-84be-15f612bfa2c7
# ╟─0c87a4eb-a8fa-4e07-a9e8-c003f201f34b
# ╠═c7d8d28f-193e-47e3-a470-973fc134230a
# ╠═0136f6d1-e765-47fc-a6ee-0024ae7515d7
# ╠═220a003e-baa9-4817-acba-c673ba6d69cc
# ╠═9179f2cf-60fb-461e-8f2e-d39a9535ad83
# ╠═86b0dbc1-771f-4388-8b7a-61690279ad25
# ╠═1f9a1c9a-e0ad-4091-bfcb-c8051ce31c15
# ╠═0c8b810b-c844-4cf1-8928-ae103e6e8426
# ╠═a15d90ac-5179-41d9-92c7-5094975ae794
# ╠═b65530c9-8545-4531-91f5-9b0dd1f963a6
# ╠═6f39f387-aa3a-4491-904b-bb5386460f3b
# ╟─5954ea63-afc0-4aa5-b97c-f62069d7c1af
# ╠═52a6ec4c-1dea-493a-b44c-22e7e3611a43
# ╠═684f5a6b-ef1e-4fd9-b1af-5a04f7c29412
# ╠═886d6052-6dcd-4707-ae2b-88b778c91e75
# ╠═55f2e127-67d5-4b2e-8838-8965fb743d7f
# ╟─8042ef7a-967f-4ade-a5e3-823e4c27c26e
# ╠═d012eba7-d339-4670-a575-8bd00ad922ff
# ╠═25d2b408-3482-4fd6-816e-b15bab9e5269
# ╟─1154e737-57b0-4f6b-9436-60d5dc9c0b4e
# ╟─6256574f-b630-438a-ae85-7f1ad3e11626
# ╠═8bebd55f-905b-43be-9889-914c42744d9a
# ╠═1790d646-3ae3-41f3-9d1c-ff5e5ce0b193
# ╟─a1a54ae3-953e-4f05-aa44-ed0e7e9dc7fa
# ╠═b7272157-db87-47f5-a979-264fe32da114
# ╠═9a5a4a64-5c1d-4be9-bc8d-c1df9b550104
# ╟─f355f587-d8f8-4102-ba89-9e9f782768b4
# ╟─cdaa9594-ccd9-4687-b8dd-c3add9b616d2
# ╟─c76f8e4a-a418-42b1-98f4-228f9ee7cd36
# ╟─5227462f-f1ef-43bc-9da6-3747e76860b8
# ╟─6a95d98c-c4e4-410a-bfd2-8f0742707405
# ╠═3237acea-2f03-4d7b-9a25-bfa2c264497a
# ╟─6da33923-0350-4b45-9bc1-03c4e44932df
# ╟─d776d731-baf9-4851-9457-ebb06aaab2d9
# ╟─76b12cef-75fc-43ba-b4ee-8f8d2b107904
# ╠═9f3a5bfd-9b49-4dfe-997c-c374a744a79d
# ╠═21a2f692-84ba-4159-b722-2c26f0d1f722
# ╠═fe5a6986-6edc-4245-8ace-30fbb038386e
# ╠═fc890d92-0619-4c65-8d2e-0eb48e466bfc
# ╟─c62c4571-5e59-4a16-9582-e2450adba584
# ╟─59dd5e1e-0289-4e6f-bca3-9d92c472030d
# ╟─5b86b8cd-7b2e-48b6-b6c1-576aa9029734
# ╟─99937b83-ac56-4e2f-bb80-a0dcaeacaae5
# ╠═a31d8977-5dcc-4f58-955e-8933f876b880
# ╠═8e4ee955-35e0-4b3e-bcf5-7b3f8accf575
# ╠═2a486c0d-1bd3-43a3-a9f9-c219d104bae8
# ╠═7f6445da-f73a-4b25-b6cc-2495c63b8f13
# ╠═8167502c-0a08-4ae9-95ee-d1d83c91343b
# ╠═2e7d5010-5705-4970-8597-6e12d491f034
# ╠═700257d5-7f56-42ae-b190-f44a85d1f212
# ╠═fc90e723-f672-4621-a454-ede3e953c254
# ╠═069751cf-08fd-4314-8a8c-094e82e4c80f
# ╠═b35380b8-4c63-4a2f-8096-683b24f0d6e4
# ╠═a467e23c-9e06-4d6e-8c21-4eee056b1c1d
# ╠═b0826444-99aa-44ed-8fc9-4cf9fa9db9ff
# ╠═5e54b929-0aee-4f00-a4a1-f2aa23f91034
# ╠═94a83162-58f6-47b8-b472-71a2ec80b74a
# ╠═508362e2-bf57-46d9-ac4a-7cf1b5e53afc
# ╠═4ddff47d-d717-4f8e-bdb2-522cd2d59c27
# ╠═75f44e0b-9c00-4893-a855-1dc673d2d302
# ╟─6c2e3ec4-cdd3-4cbb-81f0-2837284a6c9f
# ╟─aa26a951-00fd-485c-b15e-55455a9483f8
# ╟─62cf6106-a411-44eb-bbd3-1da957cb3aeb
# ╟─03888ee2-5f58-414e-b8f0-e8cf6280369d
# ╠═ed00150a-d95e-4a1f-a85a-4409366d1bf3
# ╟─84bd1e44-b998-47bb-8c7c-ee99c1f42dd4
# ╟─88a9e294-4d97-40bb-9866-ce7a0362b1b3
# ╟─52595862-4e17-4353-9c9a-a099aa50a69b
# ╟─5c8c6ed1-5b96-4464-b0e0-bf6a9b8237a4
# ╟─9d2ff719-39e4-4f47-bc47-266b8b4acdd6
# ╟─f8e7e19d-10d2-4a78-a160-1cca10f72b09
# ╠═fb49230b-a7c0-4e0b-bbab-2eab6cf25ae8
# ╠═57f9b568-2cb0-441f-bf20-7bc39bc4dd77
# ╠═7260b5d5-65d1-411e-8b20-ab6ed6491987
# ╠═257a5779-7d42-45a9-99cc-67449f8dc1e2
# ╠═21f7a95b-ec4e-43b2-8817-fc93f6aad0fd
# ╠═4e3d164d-a57a-47d4-85e5-c8dd8395e8f3
# ╠═f21dcf26-9cee-48fd-83fd-96c9a2a69024
# ╠═59285868-6aae-467d-94ab-50e8fb949eca
# ╠═28d0588b-6492-4c29-bff0-078463341c54
# ╠═4d7eb10a-43c1-4686-af10-4e38fadac34e
# ╠═2c0b8f9a-262e-44b0-a274-7b67d64419ac
# ╠═4b9e2d97-d7c4-4035-9625-48c738d338de
# ╠═93212185-d224-40b2-a783-f80f57049828
# ╠═15f92db3-2027-4bb9-b7df-67908745fef7
# ╠═978ee41a-6cb5-43ae-9fdb-6ae259082f2e
# ╠═ae52c5f4-e4cc-499f-9c39-10a894d03608
# ╠═47fd9021-cdc2-4809-8499-55750768d3bc
