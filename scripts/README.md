`experiments.toml`
---
Defines the simulation parameters for a single run of the `run.sh` or `01_run.jl`.

`run.sh`
---
Defines the slurm cluster variables (partition, nodes, cpus, etc.). Created for a conveniet way to add a job to the slurm queue with sbatch. Internally `01_run.jl` is called.

`01_run.jl`
---
Script that simulates the data based on the given parameters and computes the pvalue and power based on the specified analysis method.
The input to the script is a .toml-file (see [example](../experiments.toml)) listing the simulation parameters and a path to the destination to save the power matrices

`02_figure_powercontour_single.jl`
---


`03_figure_powercontour_multiple.jl`
---


`04_figure_type1error_single.jl`
---


`05_figure_type1error_multiple.jl`
---


`06_figure_power_twostagevslmm.jl`
---
