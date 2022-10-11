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

# ╔═╡ 394bcbe9-fcc8-4256-a5c2-211f34f8d34e
import Pkg

# ╔═╡ d0f41050-17d1-4720-990b-15750e6a0b1f
Pkg.activate("/Users/luis/test")

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

# ╔═╡ d75bebda-80cd-485b-8c4b-c626c96ccc5c
using Plots; plotly();

# ╔═╡ 98870eb3-fcbc-4047-b8b9-3779aa0c695c
using UnfoldSim

# ╔═╡ b362ddf8-ca69-42db-84ec-06ddbfd9cd64
using Unfold

# ╔═╡ 8042ef7a-967f-4ade-a5e3-823e4c27c26e
using MixedModels: zerocorr

# ╔═╡ 8bfbdf2e-ab18-4db3-9150-d2db97adfcee
using CategoricalArrays

# ╔═╡ 0465ef79-46fd-4461-a5c6-155775a90c86
md"#### Imports & Config "

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
n_item_slider = md"n\_item $(@bind n_item Slider(2:2:20, default=4, show_value=true))";

# ╔═╡ 0136f6d1-e765-47fc-a6ee-0024ae7515d7
n_subj_slider = md"n\_subj $(@bind n_subj Slider(2:20, default=2, show_value=true))";

# ╔═╡ 220a003e-baa9-4817-acba-c673ba6d69cc
β1_slider = md"β1 $(@bind β1 Slider(0:0.1:2, default=1, show_value=true))";

# ╔═╡ 9179f2cf-60fb-461e-8f2e-d39a9535ad83
β2_slider = md"β2 $(@bind β2 Slider(0:0.1:1, default=0.5, show_value=true))";

# ╔═╡ 86b0dbc1-771f-4388-8b7a-61690279ad25
σranef1_slider = md"σranef1 $(@bind σranef1 Slider(0:0.5:2, default=0, show_value=true))";

# ╔═╡ 1f9a1c9a-e0ad-4091-bfcb-c8051ce31c15
σranef2_slider = md"σranef2 $(@bind σranef2 Slider(0:0.5:2, default=0, show_value=true))";

# ╔═╡ 0c8b810b-c844-4cf1-8928-ae103e6e8426
σranef3_slider = md"σranef3 $(@bind σranef3 Slider(0:0.5:2, default=0, show_value=true))";

# ╔═╡ a15d90ac-5179-41d9-92c7-5094975ae794
σres_slider = md"σres $(@bind σres Slider(0.0001:0.0001:0.001, default=0.0001, show_value=true))";

# ╔═╡ b65530c9-8545-4531-91f5-9b0dd1f963a6
noiselevel_slider = md"noiselevel $(@bind noiselevel Slider(0:0.5:4, default=0.5, show_value=true))";

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
	], class="plutoui-sidebar aside first")
end

# ╔═╡ 5954ea63-afc0-4aa5-b97c-f62069d7c1af
md"# Define design & parameters"

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
		#@formula(dv ~ 1 + stimType + (1 + stimType | subj) + (1 | item)), #formula
		@formula(dv ~ 1 + stimType + (1 + stimType|subj)),
		Dict(:stimType => DummyCoding()), # contrast coding
		[β1, β2], # effect sizes
		#[[σranef1, σranef2], [σranef3]], # ranef variances
		[[σranef1, σranef2]],
		σres # residual variance
	)
	
	# define seed
	rng = MersenneTwister(0)

	# construct simulation 
	simulation = Simulation(
		design, # experiment design
		[p100], # components
		125, # epochlen
		305, #fixationlen
		WhiteNoise(), # noisetype
		noiselevel # noiselevel
	)
end;

# ╔═╡ b40f3252-ae1f-42b0-acc1-0fcd1b006c3c
noisetype = WhiteNoise()

# ╔═╡ 7a67638b-3000-49ff-b9b6-65ab9702c929
replace(string(noisetype), "UnfoldSim."=>"", "()" => "")

# ╔═╡ 25d2b408-3482-4fd6-816e-b15bab9e5269
designdata = select!(generate(design), [:subj, :item, :stimType]);

# ╔═╡ 52a6ec4c-1dea-493a-b44c-22e7e3611a43
designdata

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

# ╔═╡ cdaa9594-ccd9-4687-b8dd-c3add9b616d2
l1 = designdata.subj .* designdata.item .* " (" .* designdata.stimType .* ")";

# ╔═╡ 1790d646-3ae3-41f3-9d1c-ff5e5ce0b193
# ╠═╡ show_logs = false
plot(erps, 
	title="Erps", 
	label=permutedims(hcat(l1)), 
	ls=hcat(repeat(0:5:(2-1)*5, outer=2))', 
	color=hcat(repeat(1:n_subj, inner=n_item))'
)

# ╔═╡ 6a95d98c-c4e4-410a-bfd2-8f0742707405
md"# Simulation (2)"

# ╔═╡ 3237acea-2f03-4d7b-9a25-bfa2c264497a
eeg, onsets = simulate(rng, simulation);

# ╔═╡ d776d731-baf9-4851-9457-ebb06aaab2d9
l2 = collect(Set(designdata.subj));

# ╔═╡ 6da33923-0350-4b45-9bc1-03c4e44932df
plot(
	eeg, 
	title="EEG", 
	label=permutedims(hcat(l2)),
	ylim=(-3.5, 3.5)
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
end

# ╔═╡ 6c2e3ec4-cdd3-4cbb-81f0-2837284a6c9f
md"# Fit model"

# ╔═╡ 409ba386-d79f-422d-97e9-3945494532ff
# ╠═╡ show_logs = false
# ╠═╡ disabled = true
#=╠═╡
begin
	subjects = ["S"*string(i) for i in 1:n_subj];
	condA_unfold = fit_unfold_model.((evts,), (data,), subjects, ("condA", ))
	condB_unfold = fit_unfold_model.((evts,), (data,), subjects, ("condB", ))
	plot(condA_unfold, ls=0, color=vcat(1:n_subj)', title="With Unfold Model per subject x condition")
	plot!(condB_unfold, ls=5, color=vcat(1:n_subj)')
end
  ╠═╡ =#

# ╔═╡ 5b86b8cd-7b2e-48b6-b6c1-576aa9029734
"""
Fit unfold
"""
function fit_unfold_model(evts, data, subj, cond)
	# basisfunction via FIR basis
	basisfunction = firbasis(τ=(-0.1,1.2), sfreq=256, name="stimulus")
	
	# formula in wilikinson notation
	f  = @formula 0~0+condA+condB;

	# map basidfunction & formula into a dict
	bfDict = Dict(Any=>(f, basisfunction));

	# filter subjects events out
	subj_evts = filter(row -> row.subject == subj, evts)
	
	# fit model
	m = fit(UnfoldModel, bfDict, subj_evts, data);

	# create result dataframe
	results = coeftable(m);

	cond_unfold = filter(row->row.coefname==cond, results).estimate

	return cond_unfold
end;

# ╔═╡ 06a7b31b-9736-459e-887f-e4d91066b3ad
begin
	evts.subject  = categorical(Array(evts.subject))
	#evts.cond  = categorical(Array(evts.cond))
	
	# basisfunction via FIR basis
	basisfunction = firbasis(τ=(-0.1,1.2), sfreq=256, name="stimulus")
	
	# formula in wilikinson notation
	#f = @formula 0~1+cond+(1+cond|subject) + (1|stimulus)
	#f  = @formula 0~condA+condB+(1|subject)
	f = @formula(0 ~ 0 + condA + condB + (0 + condA + condB|subject))


	# map basidfunction & formula into a dict
	bfDict = Dict(Any=>(f, times));

	# filter subjects events out
	#subj_evts = filter(row -> row.subject == subj, evts)
	
	# fit model
	m = fit(UnfoldModel, bfDict, evts, Base.convert(Array{Float64, 3}, data_epoch))

	# create result dataframe
	results = coeftable(m);
end

# ╔═╡ e5adb4fe-3a9a-4d2f-b28d-00dde62a3a58
results

# ╔═╡ 35cfc76d-d7ba-4672-9820-65b9d3887d7e
condA = filter(row->row.coefname=="condA", results).estimate

# ╔═╡ 334ffd95-75ff-4c45-b301-83b71af733c4
condB = filter(row->row.coefname=="condB", results).estimate

# ╔═╡ aa26a951-00fd-485c-b15e-55455a9483f8
plot(times, [condA[1:334], condB[1:334]])

# ╔═╡ 28128e0a-72ac-46ea-939f-6a971a0b9dbc
length(condA)

# ╔═╡ 930d6872-d772-444e-bada-77a991baaa15
length(times)

# ╔═╡ fdc1b04c-4ba0-4abf-932f-060dbb79bb80
evts.stimulus = parse.(Int, (replace.(evts.stimulus, "I"=>"")))

# ╔═╡ 88a9e294-4d97-40bb-9866-ce7a0362b1b3
md"# End"

# ╔═╡ 52595862-4e17-4353-9c9a-a099aa50a69b
html"<button onclick=present()>Present</button>"

# ╔═╡ Cell order:
# ╟─0465ef79-46fd-4461-a5c6-155775a90c86
# ╠═394bcbe9-fcc8-4256-a5c2-211f34f8d34e
# ╠═d0f41050-17d1-4720-990b-15750e6a0b1f
# ╟─6374d2e3-366e-4ebb-a78f-18a636da2a54
# ╠═d75bebda-80cd-485b-8c4b-c626c96ccc5c
# ╠═98870eb3-fcbc-4047-b8b9-3779aa0c695c
# ╠═b362ddf8-ca69-42db-84ec-06ddbfd9cd64
# ╟─2e658587-b126-4f43-84be-15f612bfa2c7
# ╟─0c87a4eb-a8fa-4e07-a9e8-c003f201f34b
# ╟─c7d8d28f-193e-47e3-a470-973fc134230a
# ╟─0136f6d1-e765-47fc-a6ee-0024ae7515d7
# ╟─220a003e-baa9-4817-acba-c673ba6d69cc
# ╟─9179f2cf-60fb-461e-8f2e-d39a9535ad83
# ╟─86b0dbc1-771f-4388-8b7a-61690279ad25
# ╟─1f9a1c9a-e0ad-4091-bfcb-c8051ce31c15
# ╟─0c8b810b-c844-4cf1-8928-ae103e6e8426
# ╟─a15d90ac-5179-41d9-92c7-5094975ae794
# ╟─b65530c9-8545-4531-91f5-9b0dd1f963a6
# ╟─5954ea63-afc0-4aa5-b97c-f62069d7c1af
# ╟─52a6ec4c-1dea-493a-b44c-22e7e3611a43
# ╠═8042ef7a-967f-4ade-a5e3-823e4c27c26e
# ╠═d012eba7-d339-4670-a575-8bd00ad922ff
# ╠═b40f3252-ae1f-42b0-acc1-0fcd1b006c3c
# ╠═7a67638b-3000-49ff-b9b6-65ab9702c929
# ╟─25d2b408-3482-4fd6-816e-b15bab9e5269
# ╟─1154e737-57b0-4f6b-9436-60d5dc9c0b4e
# ╟─6256574f-b630-438a-ae85-7f1ad3e11626
# ╠═8bebd55f-905b-43be-9889-914c42744d9a
# ╟─1790d646-3ae3-41f3-9d1c-ff5e5ce0b193
# ╟─cdaa9594-ccd9-4687-b8dd-c3add9b616d2
# ╟─6a95d98c-c4e4-410a-bfd2-8f0742707405
# ╠═3237acea-2f03-4d7b-9a25-bfa2c264497a
# ╟─6da33923-0350-4b45-9bc1-03c4e44932df
# ╟─d776d731-baf9-4851-9457-ebb06aaab2d9
# ╟─76b12cef-75fc-43ba-b4ee-8f8d2b107904
# ╠═9f3a5bfd-9b49-4dfe-997c-c374a744a79d
# ╠═21a2f692-84ba-4159-b722-2c26f0d1f722
# ╠═fe5a6986-6edc-4245-8ace-30fbb038386e
# ╟─6c2e3ec4-cdd3-4cbb-81f0-2837284a6c9f
# ╟─409ba386-d79f-422d-97e9-3945494532ff
# ╠═5b86b8cd-7b2e-48b6-b6c1-576aa9029734
# ╠═06a7b31b-9736-459e-887f-e4d91066b3ad
# ╠═e5adb4fe-3a9a-4d2f-b28d-00dde62a3a58
# ╠═35cfc76d-d7ba-4672-9820-65b9d3887d7e
# ╠═334ffd95-75ff-4c45-b301-83b71af733c4
# ╠═aa26a951-00fd-485c-b15e-55455a9483f8
# ╠═28128e0a-72ac-46ea-939f-6a971a0b9dbc
# ╠═930d6872-d772-444e-bada-77a991baaa15
# ╠═fdc1b04c-4ba0-4abf-932f-060dbb79bb80
# ╠═8bfbdf2e-ab18-4db3-9150-d2db97adfcee
# ╟─88a9e294-4d97-40bb-9866-ce7a0362b1b3
# ╟─52595862-4e17-4353-9c9a-a099aa50a69b
