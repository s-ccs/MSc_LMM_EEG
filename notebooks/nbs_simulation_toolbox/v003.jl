### A Pluto.jl notebook ###
# v0.19.9

using Markdown
using InteractiveUtils

# ╔═╡ 4e40fd20-a8c4-4443-b5a8-7b6f5549437d
using MixedModelsSim

# ╔═╡ 53fc8618-cd99-4c65-b3a1-dab7eed9fb85
using MixedModels

# ╔═╡ 40b13e16-7bb2-43df-864a-bc4c3d499d43
using Random

# ╔═╡ 6c6b47a1-fa1a-4ef4-a858-a4422cc862dc
using DataFrames

# ╔═╡ 5478baea-5e1a-4006-a4e7-af3e305e328b
using DSP

# ╔═╡ fe105b3a-0567-4353-a261-787b24d4d65a
using Plots

# ╔═╡ 45ac7772-5ecf-4a2d-97ed-2622d60def54
using ImageFiltering

# ╔═╡ de1a9c3b-0c4f-4520-a6c9-336aff70538b
# ╠═╡ show_logs = false
using Unfold

# ╔═╡ d07d118b-99f1-43dd-b215-baeaab1e4413
using Statistics

# ╔═╡ f4b4d3c9-642d-4eac-8c2a-4caec75590a4
using HypothesisTests

# ╔═╡ a2c279c9-c141-4dec-942a-16623bc01a6c
md"# Imports"

# ╔═╡ b281c232-0e66-469f-8f91-f250471c9c1b
plotly();

# ╔═╡ 683f452c-e103-4646-a19c-5b6801c7dfb5
md"# Implementation"

# ╔═╡ 2c644d8f-7ccd-492f-a27b-eb419d06f1c5
# 256 Hz => 256 Samples per second
# 1000 ms => 256 samples?

# ╔═╡ a62844cf-6b05-4195-93db-9addd3d2efbf
default(linewidth=2.5)

# ╔═╡ 0fee4786-54d8-4715-8594-368a5f3cdc79
md"# Statistics"

# ╔═╡ 28e425ac-57fc-435c-9763-115cd01b0efc
md"---"

# ╔═╡ 2c409e5e-f250-4100-984f-05ab78224949
md"""# Objects"""

# ╔═╡ 733141a0-2c59-423b-815e-bceefc77a755
# Experiment Design
struct ExperimentDesign
	n_subj
	n_trial
	n_item
	subj_btwn
	item_btwn
	both_win
end

# ╔═╡ 296c82e8-f525-4071-9a04-42940ac81245
struct Simulation
	design
	basis
	formula
	contrasts
	eventonsets
	noise
end

# ╔═╡ 284bacb2-fb31-45a7-9bc2-12163aeb8849
md"# Functions"

# ╔═╡ 8e3b4714-35ac-4da8-a561-b6786756db58
"""
Pads array with specified value, length
"""
function padarray(arr, len, val)
	for l in len
		pad = fill(val, abs(l))
		arr = l > 0 ? vcat(arr, pad) : vcat(pad, arr)
	end
	return arr
end

# ╔═╡ dcd23f9c-efa9-45fe-86c3-e850388b6d25
begin
	# fixed parameters for testing
	n_subj = 4
	n_trial = 1
	n_item = 10
	btwn_subj = nothing
	btwn_item = Dict("stimType" => ["A", "B"])
	both_win = nothing

	# construct experiment design
	design = ExperimentDesign(
		n_subj,
		n_trial,
		n_item,
		btwn_subj,
		btwn_item,
		both_win,
	)

	# define seed
	rng = MersenneTwister(2)

	# construct basis function
	basis = padarray(hanning(100), (-100, 100), 0);

	# wilkinson formula - random effects structure
	formula = @formula dv ~ 1 + stimType + (1 + stimType | subj) + (1 | item)

	# contrasts
	contrasts = Dict(:stimType => EffectsCoding())

	# effects sizes and variances
	β = [2.0, 0.5];
	re = [[0.0, 0.0], [0.0]]
	σ_res = 0.00001

	# define event onsets
	eventonsets = nothing

	# define noise
	noise = nothing
	
	# construct simulation 
	simulation = Simulation(
		design,
		basis,
		formula,
		contrasts,
		eventonsets,
		noise
	)
end;

# ╔═╡ 52e91736-fa3a-4ece-94b3-be6d0d80d828
plot(basis, title="Basisfunction")

# ╔═╡ 076a7b42-e855-471b-a202-d91cad1c8223
"""
Generates data frame from experiment design
"""
function generate(design)
	return sort!(DataFrame(
		MixedModelsSim.simdat_crossed(
			n_subj, 
			n_item, 
			subj_btwn=design.subj_btwn, 
			item_btwn=design.item_btwn, 
			both_win=design.both_win
		)
	))
end

# ╔═╡ 50244434-65ea-4f52-8a9b-7782033619c2
designdata = generate(design)

# ╔═╡ 1c249733-f6a4-47fe-9d87-dd69dada1c72
l = designdata.subj .* designdata.item .* " (" .* designdata.stimType .* ")";

# ╔═╡ 4d291a29-396c-47d9-bee4-c5ffab1a1029
l1 = collect(Set(designdata.subj));

# ╔═╡ 05c3f97c-27d9-4743-9e11-76c1bfdf6f0e
"""
Simulates erp data given the specified parameters 
"""
function simulate_erps(rng, design, basis, formula, contrasts, β, re, σ_res)

	# unpacking fields
	(; n_subj, n_item) = design
	
	# fit mixed model to experiment design and dummy data
	m = MixedModels.fit(
		MixedModels.MixedModel, 
		formula, 
		generate(design), 
		contrasts=contrasts
	)

	# empty epoch data
	epoch_data = zeros(Int(length(basis)), n_subj*n_item)

	# residual variance for lmm
	σ_lmm = σ_res # 0.0001
		
	# iterate over each timepoint
	for t in eachindex(basis)

		# select weight from basis
		b = basis[t]
		
		# update random effects parametes of model
		if re !== nothing
			MixedModelsSim.update!(m, [MixedModelsSim.create_re((b .* (r)./ σ_lmm)...) for r in re]...)
		end

		# simulate with new parameters
		simulate!(deepcopy(rng), m, β = b .* [β...], σ = σ_lmm)

		# save data to array
		epoch_data[t, :] = m.y
	end
	return epoch_data
end

# ╔═╡ 19526c78-489e-4fa6-b6db-a236dbb3a597
# ╠═╡ show_logs = false
# simulate erps
erps = simulate_erps(rng, design, basis, formula, contrasts, β, re, σ_res);

# ╔═╡ 2db6ab7c-322f-40e8-b47f-8674c79f7c06
# ╠═╡ show_logs = false
plot(erps, title="ERPs", ls=hcat(repeat(0:5:(2-1)*5, outer=2))', color=hcat(repeat(1:n_subj, inner=n_item))', label=permutedims(hcat(l)))

# ╔═╡ 64d68085-5a9c-4241-ab30-ea7d530006c1
"""
Simulate eeg data given a simulation design, effect sizes and variances
"""
function simulate(rng, simulation, β, re, σ_res)
	
	# unpacking fields
	(; design, basis, formula, contrasts) = simulation 

	# create epoch data / erps
	erps = simulate_erps(rng, design, basis, formula, contrasts, β, re, σ_res)


	# combine erps together to signal per subject
	aft = 305 #average fixation time in samples
	dft = 25 # max deviation from fixation time in samples
	len = (size(erps, 1) + aft + dft) * n_item + aft+dft
	
	subject_eegs = []
	onsets = []
	for s in 1:n_subj
		subject_onsets = []
		subject_eeg = zeros(rand(MersenneTwister(111*s), aft-dft:aft+dft), 1)	
		for i in 1:n_item
			push!(subject_onsets, size(subject_eeg,1))
			z = zeros(rand(MersenneTwister(s*i), aft-dft:aft+dft), 1)
			z = vcat(erps[:, (s-1)*n_item+i], z)
			subject_eeg = vcat(subject_eeg, z)
		end
		subject_eeg = vcat(subject_eeg, zeros(len - size(subject_eeg,1),1))
		push!(subject_eegs, subject_eeg)
		push!(onsets, subject_onsets)
	end
	eeg = hcat(subject_eegs...)
	onsets = hcat(onsets...)
	
	# create noise
	noise = imfilter(randn(MersenneTwister(0), length(eeg)), Kernel.gaussian((5,)))
	#noise = randn(MersenneTwister(2), length(eeg))
	noise = reshape(noise, size(eeg))
	
	# add noise to data
	noise_level = 2
	eeg = eeg + noise_level .* noise

	return eeg, onsets
end

# ╔═╡ b159b3f4-fb0b-41b3-9a93-2dd33962f89c
# simulate eeg
eeg, onsets = simulate(rng, simulation, β, re, σ_res);

# ╔═╡ a3493e3e-48fe-498d-8705-68b6026d9301
plot(eeg, title="EEG", label=permutedims(hcat(l1)))

# ╔═╡ e74967dd-5584-41e8-a661-d9a6f49581fe
"""
Function to convert output similar to unfold (data, evts)
"""
function convert(eeg, onsets, design)
	# data 
	data = eeg[:,]

	# evts
	ed = generate(design)
	evts = DataFrame()
	a = collect(0:n_subj-1) * size(eeg, 1)
	evts.latency = (onsets' .+ a)'[:,]
	evts.type .= "sim"
	evts.trialnum = 1:size(evts, 1)
	for i in Set(ed.stimType)
		evts[!, Symbol("cond"*i)] = [(i == d ? 1 : 0) for d in ed.stimType]
	end
	evts.stimulus = ed.item
	evts.subject = ed.subj
	evts.urlatency = onsets[:,]

	return data, evts
end

# ╔═╡ 74090060-9ba9-4514-bd6a-783b86423d34
data, evts = convert(eeg, onsets, design);

# ╔═╡ 80143b46-f78f-42e6-a8b5-1b72c408e357
evts

# ╔═╡ 35b9aff5-df04-4e40-bbaf-d087d17b6495
data_epoch, times = Unfold.epoch(
	data=data,
	tbl=evts,
	τ=(-0.1,1.1),
	sfreq=256
);

# ╔═╡ 9f22feaa-0e5d-43a2-a67b-17fcad4bcd67
# ╠═╡ show_logs = false
let
	c = repeat(vcat(1:n_subj), inner=n_item)
	ls = repeat([0, 5], outer=n_item*n_subj)
	p = plot(title="Epochs")
	for i in 1:size(evts, 1)
		plot!(times, data_epoch[:, :, i]', label=l[i], c=c[i], ls=ls[i])
	end
	p
end

# ╔═╡ a57db98b-4744-4260-b893-696a400a9a5e
"""
Function to average over groups / condition
"""
function create_grouped_means(data_epoch, evts, cond, group)
	gdf = groupby(evts, group)
	subject_means_cond = []
	for (k, g) in pairs(gdf)
		cond_subj_indices = filter(row -> row[cond] == 1, g).trialnum
		cond_subj_mean = mean(
			reshape(
				data_epoch[:, :, cond_subj_indices], 
				(size(data_epoch, 2), length(cond_subj_indices))
			), dims=2
		);
		push!(subject_means_cond, cond_subj_mean)
	end
	return hcat(subject_means_cond...)
end

# ╔═╡ 1cd7f747-6be0-40c9-8f16-8a02fef5471f
condA = create_grouped_means(data_epoch, evts, "condA", :subject);

# ╔═╡ f8c70ca4-cb2b-4312-998b-a364dbee8498
condB = create_grouped_means(data_epoch, evts, "condB", :subject);

# ╔═╡ 9752847a-2536-4215-9a98-2143af23a8f2
# ╠═╡ show_logs = false
plot(times, [condA, condB], ls=hcat(repeat(0:5:(2-1)*5, inner=n_subj))', color=hcat(repeat(1:n_subj, outer=2))', title="Subject Averages CondA vs CondB")

# ╔═╡ 5aac7973-2fc8-4ea6-86c0-6b0c7f4790e9
# ╠═╡ show_logs = false
begin
	σsA = std(condA, dims=2);
	σsB = std(condB, dims=2)
	
	plot(times, [mean(condA, dims=2), mean(condB, dims=2)], c=:black, ls=[0 5], title="Grand Average CondA vs CondB", ribbon=[σsA σsB] , fillalpha=.1)
end

# ╔═╡ fdbbf8fc-131c-496b-aedd-1275ce7db421
begin
	x = maximum.(eachcol(condA))
	y = maximum.(eachcol(condB))
	OneSampleTTest(x, y)
end

# ╔═╡ 72658ac7-d6cb-49ae-8879-03ee28b8f232
function fit_unfold_model(evts, data, subj, cond)
	# basisfunction via FIR basis
	basisfunction = firbasis(τ=(-0.1,1.1), sfreq=256, name="stimulus")
	
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
end

# ╔═╡ 88249ea8-6f58-4113-9843-7029e137f9cd
# ╠═╡ show_logs = false
begin
	subjects = ["S"*string(i) for i in 1:n_subj];
	condA_unfold = fit_unfold_model.((evts,), (data,), subjects, ("condA", ))
	condB_unfold = fit_unfold_model.((evts,), (data,), subjects, ("condB", ))
	
	plot(times, condA_unfold, ls=0, color=vcat(1:n_subj)', title="With Unfold Model per subject x condition")
	plot!(times, condB_unfold, ls=5, color=vcat(1:n_subj)')
end

# ╔═╡ Cell order:
# ╟─a2c279c9-c141-4dec-942a-16623bc01a6c
# ╠═4e40fd20-a8c4-4443-b5a8-7b6f5549437d
# ╠═53fc8618-cd99-4c65-b3a1-dab7eed9fb85
# ╠═40b13e16-7bb2-43df-864a-bc4c3d499d43
# ╠═6c6b47a1-fa1a-4ef4-a858-a4422cc862dc
# ╠═5478baea-5e1a-4006-a4e7-af3e305e328b
# ╠═fe105b3a-0567-4353-a261-787b24d4d65a
# ╠═b281c232-0e66-469f-8f91-f250471c9c1b
# ╠═45ac7772-5ecf-4a2d-97ed-2622d60def54
# ╠═de1a9c3b-0c4f-4520-a6c9-336aff70538b
# ╠═d07d118b-99f1-43dd-b215-baeaab1e4413
# ╠═f4b4d3c9-642d-4eac-8c2a-4caec75590a4
# ╟─683f452c-e103-4646-a19c-5b6801c7dfb5
# ╠═dcd23f9c-efa9-45fe-86c3-e850388b6d25
# ╠═50244434-65ea-4f52-8a9b-7782033619c2
# ╠═19526c78-489e-4fa6-b6db-a236dbb3a597
# ╠═b159b3f4-fb0b-41b3-9a93-2dd33962f89c
# ╠═2c644d8f-7ccd-492f-a27b-eb419d06f1c5
# ╠═74090060-9ba9-4514-bd6a-783b86423d34
# ╠═80143b46-f78f-42e6-a8b5-1b72c408e357
# ╟─a62844cf-6b05-4195-93db-9addd3d2efbf
# ╟─52e91736-fa3a-4ece-94b3-be6d0d80d828
# ╟─2db6ab7c-322f-40e8-b47f-8674c79f7c06
# ╟─a3493e3e-48fe-498d-8705-68b6026d9301
# ╠═35b9aff5-df04-4e40-bbaf-d087d17b6495
# ╟─9f22feaa-0e5d-43a2-a67b-17fcad4bcd67
# ╠═1cd7f747-6be0-40c9-8f16-8a02fef5471f
# ╠═f8c70ca4-cb2b-4312-998b-a364dbee8498
# ╠═9752847a-2536-4215-9a98-2143af23a8f2
# ╠═88249ea8-6f58-4113-9843-7029e137f9cd
# ╠═5aac7973-2fc8-4ea6-86c0-6b0c7f4790e9
# ╟─0fee4786-54d8-4715-8594-368a5f3cdc79
# ╠═fdbbf8fc-131c-496b-aedd-1275ce7db421
# ╟─28e425ac-57fc-435c-9763-115cd01b0efc
# ╟─1c249733-f6a4-47fe-9d87-dd69dada1c72
# ╟─4d291a29-396c-47d9-bee4-c5ffab1a1029
# ╟─2c409e5e-f250-4100-984f-05ab78224949
# ╠═733141a0-2c59-423b-815e-bceefc77a755
# ╠═296c82e8-f525-4071-9a04-42940ac81245
# ╟─284bacb2-fb31-45a7-9bc2-12163aeb8849
# ╠═076a7b42-e855-471b-a202-d91cad1c8223
# ╠═8e3b4714-35ac-4da8-a561-b6786756db58
# ╠═05c3f97c-27d9-4743-9e11-76c1bfdf6f0e
# ╠═64d68085-5a9c-4241-ab30-ea7d530006c1
# ╠═e74967dd-5584-41e8-a661-d9a6f49581fe
# ╠═a57db98b-4744-4260-b893-696a400a9a5e
# ╠═72658ac7-d6cb-49ae-8879-03ee28b8f232
