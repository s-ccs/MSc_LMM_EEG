### A Pluto.jl notebook ###
# v0.19.9

using Markdown
using InteractiveUtils

# ╔═╡ 83ceb926-2db6-11ed-0bfb-c17d96750abf
md"# Pipeline"

# ╔═╡ 411c3f7c-7b16-4093-9b0c-444ce7643e9f
md"## 1) Load data"

# ╔═╡ 629182de-fb8a-42c0-b9c2-2e99d0d29f94
md"""
- EEG data, BIDS Format, multiple subject & trials?, N170 / N400 / P300
- not filtered / cleaned
- dimension: subjects * trials * channels
"""

# ╔═╡ 11a4c529-82de-4c8c-b130-58366dcb864d
md"## 2) Preprocessing"

# ╔═╡ d9b3ac74-68b1-4676-849a-b1b63427526b
md"""
- if cleaned data not available => cleaning
- filtering => highpass / lowpass / bandstop / bandpass 
- epoching
- using mne-python? (other options)
"""

# ╔═╡ 4e7cb464-5d66-427f-8dad-c20d70b77974
md"## 3) Analysis"

# ╔═╡ 56f9c3bf-ba00-46ff-954c-c8258cbbb4db
md"""
- two-stage approach
"""

# ╔═╡ 1b0efa70-c3e6-48bb-9fa7-a16ccc3a2ebe
md"## 4) Results"

# ╔═╡ Cell order:
# ╟─83ceb926-2db6-11ed-0bfb-c17d96750abf
# ╟─411c3f7c-7b16-4093-9b0c-444ce7643e9f
# ╠═629182de-fb8a-42c0-b9c2-2e99d0d29f94
# ╟─11a4c529-82de-4c8c-b130-58366dcb864d
# ╠═d9b3ac74-68b1-4676-849a-b1b63427526b
# ╟─4e7cb464-5d66-427f-8dad-c20d70b77974
# ╠═56f9c3bf-ba00-46ff-954c-c8258cbbb4db
# ╟─1b0efa70-c3e6-48bb-9fa7-a16ccc3a2ebe
