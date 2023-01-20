`helpers.jl`
---
Directory includes some helper functions for the scripts

```julia
"""
Function to instantiate the configuration from a TOML-file
"""
function config(toml)
    ...
end
```

```julia
"""
Helper function to parse range from dict
"""
function parse_range(dict)
    ...
end
```

```julia
"""
Helper function to parse range from string
"""
function parse_range(range_str)
	...
end
```

```julia
"""
Helper function to parse noisetype from string
"""
function parse_noisetype(noisetype)
    ...
end
```