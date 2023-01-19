### A Pluto.jl notebook ###
# v0.19.9

using Markdown
using InteractiveUtils

# ╔═╡ d5a8c438-7922-4618-8496-b9aa678377e4
begin
	using CSV
	using DelimitedFiles
	using DSP
	using Random
	using LinearAlgebra
	using DataFrames
	using StatsModels
	using Plots
end

# ╔═╡ abd281a8-33ec-412e-b300-f7dcaabc41bd
include("/Users/luis/git/Unfold.jl/test/test_utilities.jl")

# ╔═╡ b75067a7-c3bc-4629-8b6d-489a64ad7afd
md"# Data format"

# ╔═╡ 228152ed-b193-4b70-a9db-53a65bd7e9c6
data, evts = loadtestdata("testCase3",dataPath = "/Users/luis/git/Unfold.jl/test/data/");

# ╔═╡ 1204053c-15c1-4a04-8f51-fe3a8d65c319
data

# ╔═╡ 1cbfbacc-2607-4683-9ba8-fc9cea8f7ffd


# ╔═╡ cf1698bc-7a67-478e-84bc-702efc8f433c
evts

# ╔═╡ b112ac0d-a25a-48be-968c-e8a68905c923
md"---"

# ╔═╡ a0bfc35b-2bf7-46d3-9f3f-4be78c9eafe5
data2, evts2 = loadtestdata("testCaseMultisubject",dataPath = "/Users/luis/git/Unfold.jl/test/data/");

# ╔═╡ 64a9fa89-063f-4c12-b844-0c95f1c52c07
length(data2), size(evts2)

# ╔═╡ d7e7e4f0-0f28-4095-a6b3-baa1c160a633
plot(data[1:29])

# ╔═╡ 54e63735-7042-4ec9-9bb9-0124dd129aea
data2

# ╔═╡ d218e54e-3009-4f12-b99a-daa98c97aca0
evts2

# ╔═╡ 543c2049-83f1-447d-acb1-52436b056656
sort(filter(row -> row.subject == 1, evts2).stimulus)

# ╔═╡ a7bd440e-8d90-4755-a585-306a66170d81
combine(groupby(evts2, :subject), :stimulus => length ∘ unique => :n_distint_B)

# ╔═╡ Cell order:
# ╟─b75067a7-c3bc-4629-8b6d-489a64ad7afd
# ╠═d5a8c438-7922-4618-8496-b9aa678377e4
# ╠═abd281a8-33ec-412e-b300-f7dcaabc41bd
# ╠═228152ed-b193-4b70-a9db-53a65bd7e9c6
# ╠═1204053c-15c1-4a04-8f51-fe3a8d65c319
# ╠═1cbfbacc-2607-4683-9ba8-fc9cea8f7ffd
# ╠═cf1698bc-7a67-478e-84bc-702efc8f433c
# ╟─b112ac0d-a25a-48be-968c-e8a68905c923
# ╠═a0bfc35b-2bf7-46d3-9f3f-4be78c9eafe5
# ╠═64a9fa89-063f-4c12-b844-0c95f1c52c07
# ╠═d7e7e4f0-0f28-4095-a6b3-baa1c160a633
# ╠═54e63735-7042-4ec9-9bb9-0124dd129aea
# ╠═d218e54e-3009-4f12-b99a-daa98c97aca0
# ╠═543c2049-83f1-447d-acb1-52436b056656
# ╠═a7bd440e-8d90-4755-a585-306a66170d81
