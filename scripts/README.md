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
Creates a single power contour plot of the following kind for all power matrices in the specified src directory:

<img src="https://github.com/s-ccs/MSc_LMM_EEG/blob/main/plots/single-model%3Dtwostage_nitems%3D2:2:50_noiselevel%3D1.0_noisetype%3Dpink_nsubjs%3D3:2:49_beta%3D%5B2.0%2C%200.5%5D_ranef%3D(:subj%20%3D%3E%20%5B0.0%200.0%3B%200.0%201.0%5D)_res%3D0.0001.png" width="25%" height="25%">

`03_figure_powercontour_multiple.jl`
---
Creates a triplet (two-stage, lmm, difference) of the following kind for all power matrices in the specified src directory:

<img src="https://github.com/s-ccs/MSc_LMM_EEG/blob/main/plots/triplet-nitems%3D2:2:50_noiselevel%3D1.0_noisetype%3Dpink_nsubjs%3D3:2:49_beta%3D%5B2.0%2C%200.5%5D_ranef%3D(:subj%20%3D%3E%20%5B0.0%200.0%3B%200.0%201.0%5D)_res%3D0.0001.png" width="75%" height="75%">

`04_figure_type1error_single.jl`
---
Creates a single type 1 error plot of the following kind for all power matrices in the specified src directory:
<img src="https://github.com/s-ccs/MSc_LMM_EEG/blob/main/plots/triplet-nitems%3D2:2:50_noiselevel%3D1.0_noisetype%3Dpink_nsubjs%3D3:2:49_beta%3D%5B2.0%2C%200.5%5D_ranef%3D(:subj%20%3D%3E%20%5B0.0%200.0%3B%200.0%201.0%5D)_res%3D0.0001.png" width="75%" height="75%">


`05_figure_type1error_multiple.jl`
---
Creates a single type 1 error plot of the following kind:
> Filters need to be adapted within the code!
<img src="https://github.com/s-ccs/MSc_LMM_EEG/blob/main/plots/type1-subjint-model%3Dlmmperm_noiselevel%3D1.0_noisetype%3Dpink_beta%3D%5B2.0%2C%200.0%5D_res%3D0.0001.png" width="75%" height="75%">


`06_figure_power_twostagevslmm.jl`
---
Creates a plot of a power comparison of the twostage vs lmm for a fixed number of subjects of the following kind:
> Filters need to be adapted within the code!
<img src="https://github.com/s-ccs/MSc_LMM_EEG/blob/main/plots/power-twostagevslmm-subjint-noiselevel%3D1.0_noisetype%3Dpink_nsubj%3D3_beta%3D%5B2.0%2C%200.5%5D_res%3D0.0001.png" width="75%" height="75%">