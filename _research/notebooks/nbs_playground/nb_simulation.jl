### A Pluto.jl notebook ###
# v0.19.9

using Markdown
using InteractiveUtils

# ╔═╡ c4908567-7f54-46af-8b0c-1d3461249843
begin
	using MixedModelsSim
	using MixedModels
	using DataFrames
	using Tables
	using DSP
	using Random
	using Plots
end

# ╔═╡ 32a8d91c-e193-11ec-2e79-417c4627c8be


# ╔═╡ 4d388d01-68d5-4c2d-96a1-f5ed5bb75ef0
begin
	n_sub = 2
    n_item = 2
	rng = MersenneTwister(2)
	rng_copy = deepcopy(rng)
end

# ╔═╡ ad46829f-bef8-4bc0-998f-f471697cb198
begin
	subj_btwn = item_btwn = both_win = nothing
	
	item_btwn = Dict("stimType" => ["I", "II"])

	# simulate data based on experimental conditions
	evt = DataFrame(
        simdat_crossed(
            n_sub,
            n_item,
            subj_btwn = subj_btwn,
            item_btwn = item_btwn,
            both_win = both_win,
        ),
    )
end

# ╔═╡ 5d9b2636-e929-40e8-86e6-bcdfe1c0fdf3
filter(row -> row.subj == "S1", evt)

# ╔═╡ 9b66c550-8617-43ae-afc5-8c9186a28976
begin
	f1 = @formula dv ~ 1 + stimType + (1 + stimType | subj) + (1 | item)
	
	m = MixedModels.fit(MixedModel, f1, evt)
end

# ╔═╡ 332bc5d2-5538-4885-aa3e-79b8af2b5b64
begin
	τ = 10
    fs = 12
    β = [2.0, -1.0]
    σs1 = [1, 1, 10]
    σ = 1
end

# ╔═╡ 962726f5-0889-4cad-86a0-26fd92acfa74
function gen_han(τ, fs, peak)
    hanLen = Int(τ * fs / 3)
    han = hanning(hanLen, zerophase = false)
    sig = zeros(Int(τ * fs))
    sig[1+hanLen*(peak-1):hanLen*peak] .= han
    return sig
end

# ╔═╡ 6d5e4de9-176f-445d-af5a-eb4908e61278
begin
	basis = gen_han(τ, fs, 2)
	
	epoch_dat = zeros(Int(τ * fs), size(evt, 1))

	
	σ_lmm = .0001
	σs = σs1 ./ σ_lmm

	for t = 1:size(epoch_dat, 1)
		b = basis[t]

		# set random effects
		#MixedModelsSim.update!(m, 
		#	create_re(0.1.*b .* σs[1], 0.1.*b .* σs[2]), 
		#	create_re(0.1.*b .* σs[3])
		#)
		MixedModelsSim.update!(m, 
			create_re(b .* σs[1], b .* σs[2]), 
			create_re(b .* σs[3])
		)

		# betas
		simulate!(deepcopy(rng_copy), m, β = [b .* β[1], b .* β[2]], σ = σ_lmm)


		epoch_dat[t, :] = m.y
	end

	epoch_dat = reshape(epoch_dat, (1, size(epoch_dat)...))
end

# ╔═╡ 8b3f8240-3f25-4cad-9e55-db24550645ef
b = basis[1]

# ╔═╡ 868d0519-103e-47e1-bebc-45d98127081e
create_re(0 .* σs[1], 0 .* σs[2])

# ╔═╡ 7182a6d0-5228-4933-9fb2-e80a2f3cab31
epoch_dat[:,:,1];

# ╔═╡ a54b4775-ed37-4634-ad1c-5d064a324409
evt

# ╔═╡ 710ddf9a-adcb-4c28-b9b7-0c14bd8c4782
size(epoch_dat)

# ╔═╡ f0986052-e1cb-45c6-814b-776440fead6b
begin
	plot(epoch_dat[:,:,1]', c=1, ls=:dash)
	plot!(epoch_dat[:,:,2]', c=2, ls=:dash)
	plot!(epoch_dat[:,:,3]', c=1)
	plot!(epoch_dat[:,:,4]', c=2)
	#plot!(epoch_dat[:,:,5]', c=2)
	#plot!(epoch_dat[:,:,6]', c=3)
end

# ╔═╡ 6e23da1b-cfb0-4967-8902-2b917cb1f06e
plot(basis)

# ╔═╡ Cell order:
# ╠═32a8d91c-e193-11ec-2e79-417c4627c8be
# ╠═c4908567-7f54-46af-8b0c-1d3461249843
# ╠═4d388d01-68d5-4c2d-96a1-f5ed5bb75ef0
# ╠═ad46829f-bef8-4bc0-998f-f471697cb198
# ╠═5d9b2636-e929-40e8-86e6-bcdfe1c0fdf3
# ╠═9b66c550-8617-43ae-afc5-8c9186a28976
# ╠═332bc5d2-5538-4885-aa3e-79b8af2b5b64
# ╠═962726f5-0889-4cad-86a0-26fd92acfa74
# ╠═6d5e4de9-176f-445d-af5a-eb4908e61278
# ╠═8b3f8240-3f25-4cad-9e55-db24550645ef
# ╠═868d0519-103e-47e1-bebc-45d98127081e
# ╠═7182a6d0-5228-4933-9fb2-e80a2f3cab31
# ╠═a54b4775-ed37-4634-ad1c-5d064a324409
# ╠═710ddf9a-adcb-4c28-b9b7-0c14bd8c4782
# ╠═f0986052-e1cb-45c6-814b-776440fead6b
# ╠═6e23da1b-cfb0-4967-8902-2b917cb1f06e
