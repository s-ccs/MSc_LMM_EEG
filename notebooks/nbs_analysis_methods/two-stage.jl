### A Pluto.jl notebook ###
# v0.19.9

using Markdown
using InteractiveUtils

# ╔═╡ 499d2a2a-2db7-11ed-20b4-8b4b9b455bc4
md" # Two Stage Approach"

# ╔═╡ 37d046cf-9ce5-46c7-84b4-ba27056347ca
md"""
Data
- Matrix
- rows => subjects & trials
- columns => samples
\

Events
- DataFrame
- onsets (in samples or seconds?)
- event (stimuli / item)
- subject
- trial
\

Steps
1) Epoch data
2) Average over subjects and trials grouped by condition
3) Test for significant effect between conditions
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.2"
manifest_format = "2.0"

[deps]
"""

# ╔═╡ Cell order:
# ╟─499d2a2a-2db7-11ed-20b4-8b4b9b455bc4
# ╟─37d046cf-9ce5-46c7-84b4-ba27056347ca
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
