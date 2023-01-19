# **MSc-Thesis:** Statistically evaluating mixed-effects models for EEG analysis using large-scale simulations
**Author:** *Luis Lips*

**Supervisor(s):** *Jun.-Prof. Dr. rer. nat. Benedikt Ehinger*, *Judith Schepers, M.Sc.*

**Year:** *2022*

## Project Description
The purpose of this master thesis is to investigate the influence of a varying number of subjects, a varying number of trials per subject, and the between-subject variability on the statistical power of detecting an event with regard to selected modelling schemes. The modelling schemes selected for the comparison are the two-stage approach and linear mixed model approach. The comparison is conducted on simulated data.

This thesis was split into three main parts. The list below gives an overview over the separate goals. Mandatory goals are enumerated, optional / future goals are marked with a star (∗).

- **(A) Simulation toolbox**
	- [x] \(1) Simulating event-related responses
	- [x] \(2) Varying number of subjects, trials
	- [x] \(3) Addition of Noise (pink, white, realistic, ...)
	- [ ] \(∗) Addition of varying overlap
	- [ ] \(∗) Addition of different variance per condition
- **(B) Implementation of modelling-schemes**
	- [x] \(1) Two-way approach
	- [x] \(2) Mixed-effect models
	- [ ] \(∗) Meta-models
	- [x] \(4) Sanity check (type 1 error)
- **(C) Comparison of selected modelling-schemes varying...**
	- [x] \(1) Number of subjects
	- [x] \(2) Number of trials
	- [x] \(3) Between-subject variability
	- [ ] \(∗) Unbalanced design
	- [ ] \(∗) Within-subject variability
	- [ ] \(∗) Signal-to-noise ratio
	- [ ] \(∗) Item effects

The current version of the simulation toolbox can be found at https://github.com/unfoldtoolbox/UnfoldSim.jl.
The implementation of the modelling-schemes and the comparison is part of the current repository.

## Zotero Library Path
https://www.zotero.org/groups/4623278/master_thesis_luis_2022

## Instruction for a new student
Some notes to keep in mind before diving into the step by step instructions:
- The scripts utilize the functions of the simulation toolbox [UnfoldSim.jl](https://github.com/unfoldtoolbox/UnfoldSim.jl). In the experiments of this thesis only some simulation parameters are kept variable others are fixed by design. The variable parameters are defined in [scripts/experiments.toml](scripts/experiments.toml). 

- The code and script are intended to run on a slurm cluster with multiple nodes. Running the simulation and analysis on your personal laptop can take quite some time... :/

### 0) Instantiate the project
Navigate in a shell to the current project and start a julia session
```console
$ julia --project="."
```

Open the package manager and instantiate the project
```console
julia> ]
```
```console
(MSc_LMM_EEG) pkg> instantiate
```

### 1) Specify the variable parameters
The `experiments.toml` defines the parameters for a single run. A single run can also span multiple different parameter combinations (See example below). The example below simulates data for 7.350.000 parameter combinations (= 1000(seeds) x 49(nsubj) x 50(nitems) x 1(beta) x 3(sigmaranef) x 1(sigmares) x 1(noisetype) x 1(noiselevel)). Multiple parameter values can be specified as array within the TOML-file (`noiselevel = [1.0, 2.0]`). 

```TOML
seed = {start = 1, step = 1, end = 1000} 	# seeds to simulate data on
nsubj = {start = 3, step = 2, end = 50}  	# number of subjects in experiment design
nitem = {start = 2, step = 2, end = 50}		# number of items in experiment design
beta = [[2.0, 0.5]]				# effect sizes
sigmaranef = [					# random effect variances 
	{subj = [0.0, 0.0]}, 
	{subj = [0.0, 0.5]}, 
	{subj = [0.0, 1.0]},
]
sigmares = 0.0001				# residual variance of the mixed model
noisetype = "pink"				# noisetype
noiselevel = 1.0				# noiselevel
```

### 2) Adjust the SLURM variables to your needs and possible ressources
The `run.sh` file specifies the slurm cluster variables and calls the julia script `01_run.jl` to start the simulation and analysis. 
Adjust the the slurm variables with regard to the usable partitions and ressources available.

### 3A) Add slurm job to the queue
```console
$ sbatch scripts/run.sh {path/to/experiments.toml} {path/to/datadir}
```

### 3B) Run script in no SLURM envirionment
> Takes significantly longer! Not recommended!
```console
$ julia --project=. --optimize=3 scripts/01_run.jl {path/to/experiments.toml} {path/to/datadir}
```

### 4) Create figures
Adapt scripts 02-06 (srcdir, filters, etc.) and execute each to create the respective plots. 

```console
$ julia --project=. scripts/02_figure_powercontour_single.jl
```

```console
$ julia --project=. scripts/03_figure_powercontour_triplets.jl
```


## Overview of Folder Structure 

```
│projectdir          <- Project's main folder. It is initialized as a Git
│                       repository with a reasonable .gitignore file.
│
├── report           <- **Immutable and add-only!**
│   ├── proposal     <- Proposal PDF
│   ├── thesis       <- Final Thesis PDF
│   ├── talks        <- PDFs (and optionally pptx etc) of the Intro,
|   |                   Midterm & Final-Talk
|
├── _research        <- WIP scripts, code, notes, comments,
│   |                   to-dos and anything in an alpha state.
│
├── plots            <- All exported plots go here, best in date folders.
|   |                   Note that to ensure reproducibility it is required that all plots can be
|   |                   recreated using the plotting scripts in the scripts folder.
|
├── notebooks        <- Pluto, Jupyter, Weave or any other mixed media notebooks.*
│
├── scripts          <- Various scripts, e.g. simulations, plotting, analysis,
│   │                   The scripts use the `src` folder for their base code.
│
├── src              <- Source code for use in this project. Contains functions,
│                       structures and modules that are used throughout
│                       the project and in multiple scripts.
│
├── README.md        <- Top-level README. A fellow student needs to be able to
|   |                   continue your project. Think about her!!
|
├── .gitignore       <- focused on Julia, but some Matlab things as well
│
├── (Manifest.toml)  <- Contains full list of exact package versions used currently.
└── (Project.toml)   <- Main project file, allows activation and installation.
                        
```
