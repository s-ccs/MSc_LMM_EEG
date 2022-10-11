### A Pluto.jl notebook ###
# v0.19.9

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

# ╔═╡ d4997eeb-7b84-4170-8410-f02e087cfe74
begin
	# Imports
	
	using MixedModelsSim
	using MixedModels
	using DataFrames
	using CairoMakie
	using DSP
	using Random
	using PlutoUI
	using PlutoUI.ExperimentalLayout: vbox, hbox, Div
	using HypertextLiteral
	using ColorSchemes
	using Statistics
end

# ╔═╡ a843de36-a1fc-4a60-8c3c-4e039866afdb
"""
	:root {
			--image-filters: invert(1) hue-rotate(180deg) contrast(0.8);
			--out-of-focus-opacity: 0.5;
			--main-bg-color: hsl(0deg 0% 12%);
			--rule-color: rgba(255, 255, 255, 0.15);
			--kbd-border-color: #222222;
			--header-bg-color: hsl(30deg 3% 16%);
			--header-border-color: transparent;
			--ui-button-color: rgb(255, 255, 255);
			--cursor-color: white;
			--normal-cell: 100, 100, 100;
			--error-color: 255, 125, 125;
			--normal-cell-color: rgba(var(--normal-cell), 0.2);
			--dark-normal-cell-color: rgba(var(--normal-cell), 0.4);
			--selected-cell-color: rgb(40 147 189 / 65%);
			--code-differs-cell-color: #9b906c;
			--error-cell-color: rgba(var(--error-color), 0.6);
			--bright-error-cell-color: rgba(var(--error-color), 0.9);
			--light-error-cell-color: rgba(var(--error-color), 0);
			--export-bg-color: hsl(225deg 17% 18%);
			--export-color: rgb(255 255 255 / 84%);
			--export-card-bg-color: rgb(73 73 73);
			--export-card-title-color: rgba(255, 255, 255, 0.85);
			--export-card-text-color: rgb(255 255 255 / 70%);
			--export-card-shadow-color: #0000001c;
			--pluto-schema-types-color: rgba(255, 255, 255, 0.6);
			--pluto-schema-types-border-color: rgba(255, 255, 255, 0.2);
			--pluto-dim-output-color: hsl(0, 0, 70%);
			--pluto-output-color: hsl(0deg 0% 77%);
			--pluto-output-h-color: hsl(0, 0%, 90%);
			--pluto-output-bg-color: var(--main-bg-color);
			--a-underline: #ffffff69;
			--blockquote-color: inherit;
			--blockquote-bg: #2e2e2e;
			--admonition-title-color: black;
			--jl-message-color: rgb(38 90 32);
			--jl-message-accent-color: rgb(131 191 138);
			--jl-info-color: rgb(42 73 115);
			--jl-info-accent-color: rgb(92 140 205);
			--jl-warn-color: rgb(96 90 34);
			--jl-warn-accent-color: rgb(221 212 100);
			--jl-danger-color: rgb(100 47 39);
			--jl-danger-accent-color: rgb(255, 117, 98);
			--jl-debug-color: hsl(288deg 33% 27%);
			--jl-debug-accent-color: hsl(283deg 59% 69%);
			--table-border-color: rgba(255, 255, 255, 0.2);
			--table-bg-hover-color: rgba(193, 192, 235, 0.15);
			--pluto-tree-color: rgb(209 207 207 / 61%);
			--disabled-cell-bg-color: rgba(139, 139, 139, 0.25);
			--selected-cell-bg-color: rgb(42 115 205 / 78%);
			--hover-scrollbar-color-1: rgba(0, 0, 0, 0.15);
			--hover-scrollbar-color-2: rgba(0, 0, 0, 0.05);
			--shoulder-hover-bg-color: rgba(255, 255, 255, 0.05);
			--pluto-logs-bg-color: hsl(240deg 10% 29%);
			--pluto-logs-progress-fill: #5f7f5b;
			--pluto-logs-progress-border: hsl(210deg 35% 72%);
			--nav-h1-text-color: white;
			--nav-filepicker-color: #b6b6b6;
			--nav-filepicker-border-color: #c7c7c7;
			--nav-process-status-bg-color: rgb(82, 82, 82);
			--nav-process-status-color: var(--pluto-output-h-color);
			--restart-recc-header-color: rgb(44 106 157 / 56%);
			--restart-req-header-color: rgb(145 66 60 / 56%);
			--dead-process-header-color: rgba(250, 75, 21, 0.473);
			--loading-header-color: hsl(0deg 0% 20% / 50%);
			--disconnected-header-color: rgba(255, 169, 114, 0.56);
			--binder-loading-header-color: hsl(51deg 64% 90% / 50%);
			--loading-grad-color-1: #a9d4f1;
			--loading-grad-color-2: #d0d4d7;
			--overlay-button-bg: #2c2c2c;
			--overlay-button-border: #c7a74670;
			--overlay-button-color: white;
			--input-context-menu-border-color: rgba(255, 255, 255, 0.1);
			--input-context-menu-bg-color: rgb(39, 40, 47);
			--input-context-menu-soon-color: #b1b1b144;
			--input-context-menu-hover-bg-color: rgba(255, 255, 255, 0.1);
			--input-context-menu-li-color: #c7c7c7;
			--pkg-popup-bg: #3d2f44;
			--pkg-popup-border-color: #574f56;
			--pkg-popup-buttons-bg-color: var(--input-context-menu-bg-color);
			--black: white;
			--white: black;
			--pkg-terminal-bg-color: #252627;
			--pkg-terminal-border-color: #c3c3c388;
			--pluto-runarea-bg-color: rgb(43, 43, 43);
			--pluto-runarea-span-color: hsl(353, 5%, 64%);
			--dropruler-bg-color: rgba(255, 255, 255, 0.1);
			--jlerror-header-color: #d9baba;
			--jlerror-mark-bg-color: rgb(0 0 0 / 18%);
			--jlerror-a-bg-color: rgba(82, 58, 58, 0.5);
			--jlerror-a-border-left-color: #704141;
			--jlerror-mark-color: #b1a9a9;
			--helpbox-bg-color: rgb(30 34 31);
			--helpbox-box-shadow-color: #00000017;
			--helpbox-header-bg-color: #2c3e36;
			--helpbox-header-color: rgb(255 248 235);
			--helpbox-notfound-header-color: rgb(139, 139, 139);
			--helpbox-text-color: rgb(230, 230, 230);
			--code-section-bg-color: rgb(44, 44, 44);
			--code-section-border-color: #555a64;
			--footer-color: #cacaca;
			--footer-bg-color: rgb(38, 39, 44);
			--footer-atag-color: rgb(114, 161, 223);
			--footer-input-border-color: #6c6c6c;
			--footer-filepicker-button-color: black;
			--footer-filepicker-focus-color: #9d9d9d;
			--footnote-border-color: rgba(114, 225, 231, 0.15);
			--undo-delete-box-shadow-color: rgba(213, 213, 214, 0.2);
			--cm-editor-tooltip-border-color: rgba(0, 0, 0, 0.2);
			--cm-editor-li-aria-selected-bg-color: #3271e7;
			--cm-editor-li-aria-selected-color: white;
			--cm-editor-li-notexported-color: rgba(255, 255, 255, 0.5);
			--code-background: hsl(222deg 16% 19%);
			--cm-code-differs-gutters-color: rgb(235 213 28 / 11%);
			--cm-line-numbers-color: #8d86875e;
			--cm-selection-background: hsl(215deg 64% 59% / 48%);
			--cm-selection-background-blurred: hsl(215deg 0% 59% / 48%);
			--cm-editor-text-color: #ffe9fc;
			--cm-comment-color: #e96ba8;
			--cm-atom-color: hsl(8deg 72% 62%);
			--cm-number-color: hsl(271deg 45% 64%);
			--cm-property-color: #f99b15;
			--cm-keyword-color: #ff7a6f;
			--cm-string-color: hsl(20deg 69% 59%);
			--cm-var-color: #afb7d3;
			--cm-var2-color: #06b6ef;
			--cm-macro-color: #82b38b;
			--cm-builtin-color: #5e7ad3;
			--cm-function-color: #f99b15;
			--cm-type-color: hsl(51deg 32% 44%);
			--cm-bracket-color: #a2a273;
			--cm-tag-color: #ef6155;
			--cm-link-color: #815ba4;
			--cm-error-bg-color: #ef6155;
			--cm-error-color: #f7f7f7;
			--cm-matchingBracket-color: white;
			--cm-matchingBracket-bg-color: #c58c237a;
			--cm-placeholder-text-color: rgb(255 255 255 / 20%);
			--autocomplete-menu-bg-color: var(--input-context-menu-bg-color);
			--index-text-color: rgb(199, 199, 199);
			--index-clickable-text-color: rgb(235, 235, 235);
			--docs-binding-bg: #323431;
			--cm-html-color: #00ab85;
			--cm-html-accent-color: #00e7b4;
			--cm-css-color: #ebd073;
			--cm-css-accent-color: #fffed2;
			--cm-css-why-doesnt-codemirror-highlight-all-the-text-aaa: #ffffea;
			--cm-md-color: #a2c9d5;
			--cm-md-accent-color: #00a9d1;
		}
"""

# ╔═╡ 7ddaa28d-5ceb-4f6b-b1c5-bc10fb597d0b
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

# ╔═╡ c4e2b79b-bb0f-4c8a-9137-25c4429c42b5
begin
	sidebar = Div([@htl("""<header>
			<span class="sidebar-toggle open-sidebar">🕹</span>
     		<span class="sidebar-toggle closed-sidebar">🕹</span>
			Interactive Sliders
			</header>"""),
		md"""Here are all interactive bits of the notebook at one place.\
		Feel free to change them!"""
	], class="plutoui-sidebar aside")
end

# ╔═╡ adb8e831-f369-47f3-8b93-2d1e285e408a
slider_rng = md"""rng $(@bind s PlutoUI.Slider(1:50, show_value=true))""";

# ╔═╡ 0f40a070-c0fe-4ee9-96e1-9af9ab1c6c5c
slider_β₁ = md"""β₁ $(@bind β₁ PlutoUI.Slider(0:5:50, show_value=true))""";

# ╔═╡ 25dd3564-4905-427f-8b3a-4a5a30e078d8
slider_β₂ = md"""β₂ $(@bind β₂ PlutoUI.Slider(0:5:50, show_value=true))""";

# ╔═╡ ab909622-6ab8-4676-8076-8377665305fa
slider_β₃ = md"""β₃ $(@bind β₃ PlutoUI.Slider(0:5:50, show_value=true))""";

# ╔═╡ 7f26939f-42ad-4d89-af24-2def85ac66ea
slider_a = md"""a $(@bind a PlutoUI.Slider(0:10, show_value=true))""";

# ╔═╡ 5da1e602-a5e5-4eff-a20d-b13728461ab9
slider_b = md"""b $(@bind b PlutoUI.Slider(0:50, show_value=true))""";

# ╔═╡ 248e912f-7f61-4ea2-a5f4-042412693a2c
slider_c = md"""c $(@bind c PlutoUI.Slider(0:10, show_value=true))""";

# ╔═╡ 9bf01202-aa40-443c-925f-8106d9b09627
begin
	sidebar2 = Div([
		md""" **Sliders**""",
		slider_rng,
		md"""""",
		slider_β₁,
		slider_β₂,
		slider_β₃,
		slider_a,
		slider_b,
		slider_c
	], class="plutoui-sidebar aside second")
end

# ╔═╡ bf95ae76-62a6-484e-b8bc-4ce9a10eb934
md"""
# Helper Functions
"""

# ╔═╡ 44a2bb3a-cd43-4c3b-9010-149738b57c0e
"""
Function generate hanning window
"""
function gen_han(τ, fs, peak)
    hanLen = Int(τ * fs / 3)
    han = hanning(hanLen, zerophase = false)
    sig = zeros(Int(τ * fs))
    sig[1+hanLen*(peak-1):hanLen*peak] .= han
    return sig
end

# ╔═╡ 9163ceda-080b-11ed-0685-7db1269a6055
md"""
## 2x2 :  y ~ 1 + (1 | subject)
"""

# ╔═╡ 6463f0e5-bb1d-405a-8308-e0dcf598451e
# ╠═╡ disabled = true
#=╠═╡
let
	# random seed
	rng = MersenneTwister(s)
	rng_copy = deepcopy(rng)

	# number of subjects, items
	n_sub = 2
    n_item = 2

	# simulate experimetn conditions with dummy values (dv)
	subj_btwn = item_btwn = both_win = nothing
	#item_btwn = Dict("stimType" => ["I", "II"]) # needed?
	evt = DataFrame(simdat_crossed(n_sub, n_item, subj_btwn = subj_btwn, item_btwn 
		= item_btwn, both_win = both_win,),)

	# formula
	f = @formula dv ~ 1 + (1|subj)

	# mixed model 
	m = MixedModels.fit(MixedModel, f, evt)

	# new parameters for simulation
	τ = 10 
	fs = 12 
	peak = 2
    β = [β₁, β₂] 
    σs1 = [a, b, c]
    σ = 1 #??? (never used?)
	σ_lmm = .00001 
	σs = σs1 ./ σ_lmm

	# initialize empty matrix (samples * groups) & basisfunction
	epoch_dat = zeros(Int(τ * fs), size(evt, 1)) 
	basis = gen_han(τ, fs, peak) 

	# iterate over each timepoint
	for t = 1:size(epoch_dat, 1)
		b = basis[t]

		# update random effects structure of dummy model 
		MixedModelsSim.update!(m, 
			subj=create_re(b .* σs[1])
		)
		
		# simulate with new random effects structure
		simulate!(
			deepcopy(rng_copy), 
			m, 
			β = [b .* β[1]],#, b .* β[2]],
			σ = σ_lmm)
		
		epoch_dat[t, :] = m.y
	end	

	# additional stuff for plotting
	fig = Figure()
	ax = Axis(fig[1, 1])
	limits!(ax, 0, 120, -60, 60)
	
	ls = [nothing, nothing]#, :dash]
	colors = ColorSchemes.tab10[:]#repeat(ColorSchemes.tab10[:], inner=2)
	
	for i in 1:2*2
		lines!(epoch_dat[:,i], linestyle=ls[(i%2)+1], color=colors[i], label="$(evt.subj[i])-$(evt.item[i])")
	end

	evt.dv = epoch_dat'[:,60]
	m2 = MixedModels.fit(MixedModel, f, evt)

	print(m2)
	
	current_figure()
end
  ╠═╡ =#

# ╔═╡ 1020d52b-c831-4e1b-a3b8-eca2a20caa3a
md"""
## 2x2 :  y ~ -1 + (1 | subject)
"""

# ╔═╡ 0c60e8bc-18ec-4f5e-ba08-29c8bb0ab789
# ╠═╡ disabled = true
#=╠═╡
let
	# random seed
	rng = MersenneTwister(s)
	rng_copy = deepcopy(rng)

	# number of subjects, items
	n_sub = 10
    n_item = 2

	# simulate experimetn conditions with dummy values (dv)
	subj_btwn = item_btwn = both_win = nothing
	#item_btwn = Dict("stimType" => ["I", "II"]) # needed?
	evt = DataFrame(simdat_crossed(n_sub, n_item, subj_btwn = subj_btwn, item_btwn 
		= item_btwn, both_win = both_win,),)

	# formula
	f = @formula dv ~ -1 + (1|subj)

	# mixed model 
	m = MixedModels.fit(MixedModel, f, evt)

	println(ranef(m))

	# new parameters for simulation
	τ = 10 
	fs = 12 
	peak = 2
    #β = [β₁, β₂] 
    σs1 = [a]
    σ = 1 #??? (never used?)
	σ_lmm = .00001 
	σs = σs1 ./ σ_lmm

	# initialize empty matrix (samples * groups) & basisfunction
	epoch_dat = zeros(Int(τ * fs), size(evt, 1)) 
	basis = gen_han(τ, fs, peak) 

	# iterate over each timepoint
	for t = 1:size(epoch_dat, 1)
		b = basis[t]

		# update random effects structure of dummy model 
		MixedModelsSim.update!(m, 
			subj=create_re(b .* σs[1])
		)
		
		# simulate with new random effects structure
		simulate!(
			deepcopy(rng_copy), 
			m, 
			β = [],#[b .* β[1], b .* β[2], 1],
			σ = σ_lmm)
		
		epoch_dat[t, :] = m.y
	end	

	# additional stuff for plotting
	fig = Figure()
	ax = Axis(fig[1, 1])
	limits!(ax, 0, 120, -60, 60)
	
	ls = [nothing, nothing]#, :dash]
	colors = ColorSchemes.tab10[:]#repeat(ColorSchemes.tab10[:], inner=2)
	
	for i in 1:2*2
		lines!(epoch_dat[:,i], linestyle=ls[(i%2)+1], color=colors[i], label="$(evt.subj[i])-$(evt.item[i])")
	end
	
	evt.dv = epoch_dat'[:,60]
	m2 = MixedModels.fit(MixedModel, f, evt)

	println(m2)
	
	current_figure()
end
  ╠═╡ =#

# ╔═╡ 769f906d-0228-44bd-94b9-fcc3877d49db
md"""
## 2x2 :  y ~ 1 + subj + (1 + item | subject) + (1|item)
"""

# ╔═╡ c47c923b-84d1-4cb4-baa3-78cea04166de
# ╠═╡ disabled = true
#=╠═╡
let
	# random seed
	rng = MersenneTwister(s)
	rng_copy = deepcopy(rng)

	# number of subjects, items
	n_sub = 2
    n_item = 2

	# simulate experimetn conditions with dummy values (dv)
	subj_btwn = item_btwn = both_win = nothing
	#item_btwn = Dict("stimType" => ["I", "II"]) # needed?
	evt = DataFrame(simdat_crossed(n_sub, n_item, subj_btwn = subj_btwn, item_btwn 
		= item_btwn, both_win = both_win,),)

	#sort!(evt, [:subj, :item], rev=[false, true])
	sort!(evt)
	
	# formula
	f = @formula dv ~ 1 + subj + (1 + item|subj) + (1|item)

	# mixed model 
	m = MixedModels.fit(MixedModel, f, evt)
	#print(ranef(m))

	# new parameters for simulation
	τ = 10 
	fs = 12 
	peak = 2
    β = [β₁, β₂] 
    σs1 = [a, b, c]
    σ = 1 #??? (never used?)
	σ_lmm = .00001 
	σs = σs1 ./ σ_lmm

	# initialize empty matrix (samples * groups) & basisfunction
	epoch_dat = zeros(Int(τ * fs), size(evt, 1)) 
	basis = gen_han(τ, fs, peak) 

	# iterate over each timepoint
	for t = 1:size(epoch_dat, 1)
		b = basis[t]

		# update random effects structure of dummy model 
		MixedModelsSim.update!(m, 
			subj=create_re(b .* σs[1], b .* σs[2]),
			item=create_re(b .* σs[3])
		)
		
		# simulate with new random effects structure
		simulate!(
			deepcopy(rng_copy), 
			m, 
			β = [b .* β[1], b .* β[2]],
			σ = σ_lmm)
		
		epoch_dat[t, :] = m.y
	end	

	# additional stuff for plotting
	fig = Figure()
	ax = Axis(fig[1, 1])
	limits!(ax, 0, 120, -60, 60)
	
	ls = [nothing, :dash]
	colors = repeat(ColorSchemes.tab10[:], inner=2)
	
	for i in 1:2*2
		lines!(epoch_dat[:,i], linestyle=ls[(i%2)+1], color=colors[i], label="$(evt.subj[i])-$(evt.item[i])")
	end

	evt.dv = epoch_dat'[:,60]
	m2 = MixedModels.fit(MixedModel, f, evt)

	print(evt)
	println(m2)
	println(raneftables(m2))
	
	current_figure()
end
  ╠═╡ =#

# ╔═╡ 020f45aa-23d1-4295-be18-7f124b9c3c4c
md"""
## 2x2 :  y ~ -1 + subj + (1 + item | subject) + (1|item)
"""

# ╔═╡ 8212b071-c0e7-46d9-b24f-499b179bdfc0
# ╠═╡ disabled = true
#=╠═╡
let
	# random seed
	rng = MersenneTwister(s)
	rng_copy = deepcopy(rng)

	# number of subjects, items
	n_sub = 2
    n_item = 2

	# simulate experimetn conditions with dummy values (dv)
	subj_btwn = item_btwn = both_win = nothing
	#item_btwn = Dict("stimType" => ["I", "II"]) # needed?
	evt = DataFrame(simdat_crossed(n_sub, n_item, subj_btwn = subj_btwn, item_btwn 
		= item_btwn, both_win = both_win,),)

	#sort!(evt, [:subj, :item], rev=[false, true])
	sort!(evt)
	
	# formula
	f = @formula dv ~ -1 + subj + (1 + item|subj) + (1|item)

	# mixed model 
	m = MixedModels.fit(MixedModel, f, evt)
	#print(ranef(m))

	# new parameters for simulation
	τ = 10 
	fs = 12 
	peak = 2
    β = [β₁, β₂] 
    σs1 = [a, b, c]
    σ = 1 #??? (never used?)
	σ_lmm = .00001 
	σs = σs1 ./ σ_lmm

	# initialize empty matrix (samples * groups) & basisfunction
	epoch_dat = zeros(Int(τ * fs), size(evt, 1)) 
	basis = gen_han(τ, fs, peak) 

	# iterate over each timepoint
	for t = 1:size(epoch_dat, 1)
		b = basis[t]

		# update random effects structure of dummy model 
		MixedModelsSim.update!(m, 
			subj=create_re(b .* σs[1], b .* σs[2]),
			item=create_re(b .* σs[3])
		)
		
		# simulate with new random effects structure
		simulate!(
			deepcopy(rng_copy), 
			m, 
			β = [b .* β[1], b .* β[2]],
			σ = σ_lmm)
		
		epoch_dat[t, :] = m.y
	end	

	# additional stuff for plotting
	fig = Figure()
	ax = Axis(fig[1, 1])
	limits!(ax, 0, 120, -60, 60)
	
	ls = [nothing, :dash]
	colors = repeat(ColorSchemes.tab10[:], inner=2)
	
	for i in 1:2*2
		lines!(epoch_dat[:,i], linestyle=ls[(i%2)+1], color=colors[i], label="$(evt.subj[i])-$(evt.item[i])")
	end

	evt.dv = epoch_dat'[:,60]
	m2 = MixedModels.fit(MixedModel, f, evt)

	print(evt)
	println(m2)
	println(raneftables(m2))
	
	current_figure()
end
  ╠═╡ =#

# ╔═╡ 18052c8b-85b8-4004-8cd8-08c690a32888
md"""
## 2x3 : y ~ 1 + (1 | subject)
"""

# ╔═╡ bf4f9a09-2ace-49f4-902a-55fbfe13e64d
# ╠═╡ show_logs = false
# ╠═╡ disabled = true
#=╠═╡
let
	# random seed
	rng = MersenneTwister(s)
	rng_copy = deepcopy(rng)

	# number of subjects, items
	n_sub = 2
    n_item = 2

	# simulate experimetn conditions with dummy values (dv)
	subj_btwn = item_btwn = both_win = nothing
	#item_btwn = Dict("stimType" => ["I", "II"]) # needed?
	evt = DataFrame(simdat_crossed(n_sub, n_item, subj_btwn = subj_btwn, item_btwn 
		= item_btwn, both_win = both_win,),)

	# formula
	f = @formula dv ~ 1 + (1|subj)

	# mixed model 
	m = MixedModels.fit(MixedModel, f, evt)

	# new parameters for simulation
	τ = 10 
	fs = 12 
	peak = 2
    β = [β₁, β₂] 
    σs1 = [a, b, c]
    σ = 1 #??? (never used?)
	σ_lmm = .00001 
	σs = σs1 ./ σ_lmm

	# initialize empty matrix (samples * groups) & basisfunction
	epoch_dat = zeros(Int(τ * fs), size(evt, 1)) 
	basis = gen_han(τ, fs, peak) 

	# iterate over each timepoint
	for t = 1:size(epoch_dat, 1)
		b = basis[t]

		# update random effects structure of dummy model 
		MixedModelsSim.update!(m, 
			subj=create_re(b .* σs[1])
		)
		
		# simulate with new random effects structure
		simulate!(
			deepcopy(rng_copy), 
			m, 
			β = [b .* β[1]],#, b .* β[2]],
			σ = σ_lmm)
		
		epoch_dat[t, :] = m.y
	end	

	# additional stuff for plotting
	fig = Figure()
	ax = Axis(fig[1, 1])
	limits!(ax, 0, 120, -60, 60)
	
	ls = [nothing, nothing]#, :dash]
	colors = ColorSchemes.tab10[:]#repeat(ColorSchemes.tab10[:], inner=2)
	
	for i in 1:2*2
		lines!(epoch_dat[:,i], linestyle=ls[(i%2)+1], color=colors[i], label="$(evt.subj[i])-$(evt.item[i])")
	end

	evt.dv = epoch_dat'[:,60]
	m2 = MixedModels.fit(MixedModel, f, evt)

	print(m2)
	
	current_figure()
end
  ╠═╡ =#

# ╔═╡ 00d86269-7d4f-4338-88c4-a6ba935f41c3
md"""
## 2x3 : y ~ -1 + (1 | subject)
"""

# ╔═╡ f00825cf-9177-4cf5-81dc-093a4e1598b0
# ╠═╡ show_logs = false
# ╠═╡ disabled = true
#=╠═╡
let
	# random seed
	rng = MersenneTwister(s)
	rng_copy = deepcopy(rng)

	# number of subjects, items
	n_sub = 3
    n_item = 2

	# simulate experimetn conditions with dummy values (dv)
	subj_btwn = item_btwn = both_win = nothing
	#item_btwn = Dict("stimType" => ["I", "II"]) # needed?
	evt = DataFrame(simdat_crossed(n_sub, n_item, subj_btwn = subj_btwn, item_btwn 
		= item_btwn, both_win = both_win,),)

	# formula
	f = @formula dv ~ -1 + (1|subj)

	# mixed model 
	m = MixedModels.fit(MixedModel, f, evt)

	println(ranef(m))

	# new parameters for simulation
	τ = 10 
	fs = 12 
	peak = 2
    #β = [β₁, β₂] 
    σs1 = [a]
    σ = 1 #??? (never used?)
	σ_lmm = .00001 
	σs = σs1 ./ σ_lmm

	# initialize empty matrix (samples * groups) & basisfunction
	epoch_dat = zeros(Int(τ * fs), size(evt, 1)) 
	basis = gen_han(τ, fs, peak) 

	# iterate over each timepoint
	for t = 1:size(epoch_dat, 1)
		b = basis[t]

		# update random effects structure of dummy model 
		MixedModelsSim.update!(m, 
			subj=create_re(b .* σs[1])
		)
		
		# simulate with new random effects structure
		simulate!(
			deepcopy(rng_copy), 
			m, 
			β = [],#[b .* β[1], b .* β[2], 1],
			σ = σ_lmm)
		
		epoch_dat[t, :] = m.y
	end	

	# additional stuff for plotting
	fig = Figure()
	ax = Axis(fig[1, 1])
	limits!(ax, 0, 120, -60, 60)
	
	ls = [nothing, nothing]#, :dash]
	colors = ColorSchemes.tab10[:]#repeat(ColorSchemes.tab10[:], inner=2)
	
	for i in 1:2*2
		lines!(epoch_dat[:,i], linestyle=ls[(i%2)+1], color=colors[i], label="$(evt.subj[i])-$(evt.item[i])")
	end
	
	evt.dv = epoch_dat'[:,60]
	m2 = MixedModels.fit(MixedModel, f, evt)

	println(m2)
	
	current_figure()
end
  ╠═╡ =#

# ╔═╡ 4a4d5a5d-44bc-4920-b4cd-2b5697d215b4
md"""
## 3x2 :  y ~ 1 + subj + (1 + item | subject) + (1|item)
"""

# ╔═╡ 2e99350b-daa5-48e3-860e-35c9f47e6ff4
# ╠═╡ show_logs = false
let
	# random seed
	rng = MersenneTwister(s)
	rng_copy = rng#deepcopy(rng)

	# number of subjects, items
	n_sub = 3
    n_item = 2

	# simulate experimetn conditions with dummy values (dv)
	subj_btwn = item_btwn = both_win = nothing
	item_btwn = Dict("stimType" => ["I", "II"]) # needed?
	evt = DataFrame(simdat_crossed(n_sub, n_item, subj_btwn = subj_btwn, item_btwn 
		= item_btwn, both_win = both_win,),)

	#sort!(evt, [:subj, :item], rev=[false, true])
	sort!(evt)
	
	# formula
	f = @formula dv ~ 1 + stimType + (1 + stimType|subj) + (1|item)

	# mixed model 
	m = MixedModels.fit(MixedModel, f, evt)
	#print(ranef(m))

	# new parameters for simulation
	τ = 10 
	fs = 12 
	peak = 2
    β = [β₁, β₂, β₃]  
    σs1 = [a, b, c]
    σ = 1 #??? (never used?)
	σ_lmm = .00001 
	σs = σs1 ./ σ_lmm

	# initialize empty matrix (samples * groups) & basisfunction
	epoch_dat = zeros(Int(τ * fs), size(evt, 1)) 
	basis = gen_han(τ, fs, peak) 

	# iterate over each timepoint
	for t = 1:size(epoch_dat, 1)
		b = basis[t]

		# update random effects structure of dummy model 
		MixedModelsSim.update!(m, 
			subj=create_re(b .* σs[1], b .* σs[2]),
			item=create_re(b .* σs[3])
		)
		
		# simulate with new random effects structure
		simulate!(
			deepcopy(rng_copy), 
			m, 
			β = [b .* β[1], b .* β[2], b .* β[3]],
			σ = σ_lmm)
		
		epoch_dat[t, :] = m.y
	end	

	# additional stuff for plotting
	fig = Figure()
	ax = Axis(fig[1, 1])
	limits!(ax, 0, 120, -60, 60)
	
	ls = [nothing, :dash]
	colors = repeat(ColorSchemes.tab10[:], inner=2)
	
	for i in 1:n_sub*n_item
		lines!(epoch_dat[:,i], linestyle=ls[(i%2)+1], color=colors[i], label="$(evt.subj[i])-$(evt.item[i])")
	end

	evt.dv = epoch_dat'[:,60]
	m2 = MixedModels.fit(MixedModel, f, evt)

	print(evt)
	println(m2)
	println(raneftables(m2))
	
	current_figure()
end

# ╔═╡ 260346ce-fbd8-40a2-a033-a3c748d75e78
@formula

# ╔═╡ 67d1ab74-7381-4e47-981e-f650ec31c69e
md"""
# Generic
"""

# ╔═╡ fcf73457-8d37-4977-bd20-e79406fd6635
md"""
### Parameters
"""

# ╔═╡ d205af00-1435-4e32-a3be-b875c1000580
# ╠═╡ disabled = true
#=╠═╡
begin
	# random seed
	rng = MersenneTwister(s)
	rng_copy = deepcopy(rng)

	# number of subjects
	n_sub = 2

	# number of items
	n_item = 2

	# basis function parameters
	τ = 10 
	fs = 12 
	peak = 2

	# formula
	f = @formula dv ~ 1 + subj + (1 + item|subj) + (1|item)
	
	# new model parameters
	β = [β₁, β₂]  # depends on of fixed effects
    σs1 = [a, b, c]
	σ_lmm = .00001 
	re = [[a, b], [c]] 

	

end
  ╠═╡ =#

# ╔═╡ df49282c-1752-49c8-b738-e6da8be36009
#=╠═╡
typeof(re)
  ╠═╡ =#

# ╔═╡ dbd94ed9-bdc3-4e7c-91b8-46dfb362de95
#=╠═╡
begin

	# simulate experimetn conditions with dummy values (dv)
	subj_btwn = item_btwn = both_win = nothing
	evt = DataFrame(simdat_crossed(n_sub, n_item, subj_btwn = subj_btwn, item_btwn 
		= item_btwn, both_win = both_win,),)

	# sorting [depends on formula] (for plotting)
	sort!(evt)

	# mixed model 
	m = MixedModels.fit(MixedModel, f, evt)
end
  ╠═╡ =#

# ╔═╡ 004df210-cf67-496c-94b7-2112580c6228
#=╠═╡
begin
	# initialize empty matrix (samples * groups)
	epoch_dat = zeros(Int(τ * fs), size(evt, 1)) 
	
	# basisfunction
	basis = gen_han(τ, fs, peak) 

	# iterate over each timepoint
	for t = 1:size(epoch_dat, 1)
		b = basis[t]

		# update random effects structure of dummy model 
		MixedModelsSim.update!(m, 
			[create_re((b .* (r)./ σ_lmm)...) for r in re]...
		)
		
		# simulate with new random effects structure
		simulate!(
			deepcopy(rng_copy), 
			m, 
			β = b .* [β...],
			σ = σ_lmm)
		
		epoch_dat[t, :] = m.y
	end	
end
  ╠═╡ =#

# ╔═╡ a5a0dd17-fd37-417d-bc6e-d3df71f6b197
#=╠═╡
begin
	# additional stuff for plotting
	fig = Figure()
	ax = Axis(fig[1, 1])
	limits!(ax, 0, 120, -60, 60)
	
	ls = [nothing, :dash]
	ls2 = [:dot, :dashdot]
	colors = repeat(ColorSchemes.tab10[:], inner=2)
	
	for i in 1:n_sub*n_item
		lines!(epoch_dat[:,i], linestyle=ls[(i%2)+1], color=colors[i], label="$(evt.subj[i])-$(evt.item[i])")
	end

	evt.dv = epoch_dat'[:,60]
	m2 = MixedModels.fit(MixedModel, f, evt)

	#print(evt)
	#println(m2)
	#println(raneftables(m2))
	
	current_figure()
end
  ╠═╡ =#

# ╔═╡ Cell order:
# ╠═d4997eeb-7b84-4170-8410-f02e087cfe74
# ╟─a843de36-a1fc-4a60-8c3c-4e039866afdb
# ╟─7ddaa28d-5ceb-4f6b-b1c5-bc10fb597d0b
# ╟─c4e2b79b-bb0f-4c8a-9137-25c4429c42b5
# ╟─9bf01202-aa40-443c-925f-8106d9b09627
# ╟─adb8e831-f369-47f3-8b93-2d1e285e408a
# ╠═0f40a070-c0fe-4ee9-96e1-9af9ab1c6c5c
# ╠═25dd3564-4905-427f-8b3a-4a5a30e078d8
# ╠═ab909622-6ab8-4676-8076-8377665305fa
# ╟─7f26939f-42ad-4d89-af24-2def85ac66ea
# ╟─5da1e602-a5e5-4eff-a20d-b13728461ab9
# ╟─248e912f-7f61-4ea2-a5f4-042412693a2c
# ╟─bf95ae76-62a6-484e-b8bc-4ce9a10eb934
# ╟─44a2bb3a-cd43-4c3b-9010-149738b57c0e
# ╟─9163ceda-080b-11ed-0685-7db1269a6055
# ╟─6463f0e5-bb1d-405a-8308-e0dcf598451e
# ╟─1020d52b-c831-4e1b-a3b8-eca2a20caa3a
# ╟─0c60e8bc-18ec-4f5e-ba08-29c8bb0ab789
# ╟─769f906d-0228-44bd-94b9-fcc3877d49db
# ╟─c47c923b-84d1-4cb4-baa3-78cea04166de
# ╟─020f45aa-23d1-4295-be18-7f124b9c3c4c
# ╟─8212b071-c0e7-46d9-b24f-499b179bdfc0
# ╟─18052c8b-85b8-4004-8cd8-08c690a32888
# ╟─bf4f9a09-2ace-49f4-902a-55fbfe13e64d
# ╟─00d86269-7d4f-4338-88c4-a6ba935f41c3
# ╟─f00825cf-9177-4cf5-81dc-093a4e1598b0
# ╟─4a4d5a5d-44bc-4920-b4cd-2b5697d215b4
# ╠═2e99350b-daa5-48e3-860e-35c9f47e6ff4
# ╠═260346ce-fbd8-40a2-a033-a3c748d75e78
# ╟─67d1ab74-7381-4e47-981e-f650ec31c69e
# ╟─fcf73457-8d37-4977-bd20-e79406fd6635
# ╟─d205af00-1435-4e32-a3be-b875c1000580
# ╠═df49282c-1752-49c8-b738-e6da8be36009
# ╠═dbd94ed9-bdc3-4e7c-91b8-46dfb362de95
# ╠═004df210-cf67-496c-94b7-2112580c6228
# ╟─a5a0dd17-fd37-417d-bc6e-d3df71f6b197
