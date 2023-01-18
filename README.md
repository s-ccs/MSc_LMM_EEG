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
- code was intended to run on a cluster (SLURM) with multiple nodes
- with multiple combinations of parameters

### 1) Specify the variable parameters

```TOML
seed = {start = 1, step = 1, end = 1000} 	# seeds to simulate data on
nsubj = {start = 3, step = 2, end = 50}  	# number of subjects in experiment design
nitem = {start = 2, step = 2, end = 50}		# number of items in experiment design
beta = [[2.0, 0.5]]							# effect sizes
sigmaranef = [								# random effect variances 
        {subj = [0.0, 0.0]}, {subj = [0.0, 0.5]}, {subj = [0.0, 1.0]},
]
sigmares = [0.0001]
noisetype = "pink"
noiselevel = [2.0, 1.0]
```

2) Adjust the SLURM variables to your needs and possible ressources
- `run.sh`

3) Add slurm job to the queue
```bash
sbatch scripts/run.sh {path/to/experiments.toml} {path/to/datadir}
```

4) Run script in no SLURM envirionment
```bash
julia --project=. --optimize=3 scripts/01_run.jl {path/to/experiments.toml} {path/to/datadir}
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
├── test             <- Folder containing tests for `src`.
│   └── runtests.jl  <- Main test file
│   └── setup.jl     <- Setup test environment
│
├── README.md        <- Top-level README. A fellow student needs to be able to
|   |                   continue your project. Think about her!!
|
├── .gitignore       <- focused on Julia, but some Matlab things as well
│
├── (Manifest.toml)  <- Contains full list of exact package versions used currently.
|── (Project.toml)   <- Main project file, allows activation and installation.
└── (Requirements.txt)<- in case of python project - can also be an anaconda file, MakeFile etc.
                        
```

\*Instead of having a separate *notebooks* folder, you can also delete it and integrate your notebooks in the scripts folder. However, notebooks should always be marked by adding `nb_` in front of the file name.