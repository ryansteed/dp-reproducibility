# Replication Code for "Reproducibility of Social Science Research Using Aggregate Statistics With Noise Infused for Differential Privacy"

Paper: [Reproducibility of Social Science Research Using Aggregate Statistics With Noise Infused for
Differential Privacy](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=5906765) (forthcoming, PNAS)

Paper Authors: Ryan Steed, Eduardo Abraham Schnadower Mustri, Alessandro Acquisti

Code Contributors: Ryan Steed, Annie Qian, Donna Zhu

## Usage
### Running Replications
Setup: For all studies desired, obtain the zipped replication package, save as `source.zip`, then run `make source` and `make results` from the study directory. This will overwrite the `source/` and `results/` directories with the replication package and the replication results, respectively. To recover our changes to the source code, then run `git reset --hard` (or similar) in the study directory.

Then, to run a simple replication of a given study, run `replicate [study-id]`. (The study ID should match a subdirectory in `studies/`.)

To run a replication with different levels of epsilon-DP, run `replicate [study-id] -e [epsilon1] -e [epsilon2] ...`.

To run all available replications, use the study ID `all`: `replicate all [options]`.

To replicate all experiments:
```bash
# control
replicate all -x control -n 1

# privacy
replicate all -x privacy -nctrl -e 0.0001 -e 0.001 -e 0.01 -e 0.1 -e 1 -e 10 -e 100 -e 1000 -m laplace -m gaussian

# privacy --- continuous
replicate all -x privacy_continuous -nctrl -elog 50 -m laplace -m gaussian

# Data error
replicate all -x error -nctrl -a 0.001 -a 0.01 -a 0.05 -a 0.1 -a 0.2 -a 0.5 -a 0.8 -sh hudson-berger -sh morris-lysy
replicate all -x error_scaled -nctrl -a 0.001 -a 0.01 -a 0.05 -a 0.1 -a 0.2 -a 0.5 -a 0.8 -b 0.01 -b 0.1 -b 0.5 -cs est -sh hudson-berger

# Gaussian on the margin
replicate all -x margin -nctrl -e 0.0001 -e 0.001 -e 0.01 -e 0.1 -e 1 -e 10 -e 100 -e 1000 -m gaussian -a 0.001 -a 0.01 -a 0.05 -a 0.1 -a 0.2 -a 0.5 -a 0.8 -sh hudson-berger

# multiple imputation
replicate all -x multiple_imputation -nctrl -mo 10 -e 100 -e 10 -e 1 -e 0.1 -e 0.01 -e 0.001
```

Results are stored in a SQLITE table: `results/experiments/<experiment_name>.db`.

### Adding New Studies
New studies can be added as individual modules/plugins without modifying the `simulate_privacy` library.

To add a new study,
1. Create a subdirectory in the `studies` folder with a descriptive name (e.g. `[author]-[year]`). Templates for the required files below can be copied from `studies/templates` (`cp ../templates/* .`)
2. Add instructions for how to download the study's replication package to the `README` file.
3. Create a Makefile with two scripts (see other studies for examples):
  1. `make source` --- unzip the replication package into a subdirectory called `source/`.
  2. `make results` --- follow the authors' instructions to run their code and reproduce their results.
4. Modify the authors' code in `source/` to output the key results into the subdirectory `results/` subdirectory. Other small bug fixes and path changes to `source/` may be necessary to get their code working --- record these changes in the README. Mark any changes to `source/` with comments.
5. Create a Python module `study.py`. Create a new subclass of `simulate_privacy.studies.Study`. Set the class attribute `id` to same name as the study's subdirectory. Override the following methods (see other studies for examples):
  1. `extract_results()` --- return a list of `simulate_privacy.studies.Result` objects from the replication output stored in `results/`.
  2. `data_paths()` --- return a dictionary (name: path)  of paths to the data files necessary to produce the key results.
  3. `_noise()`, `_post_processing` --- given a dictionary (name: dataframe) of dataframes and an epsilon value, add differentially private noise, usually by passing the sensitivities of each variable to the superclass method `Study._noise()`. Implement any post-processing needed for the replication to work.

## Installation
Requires `conda` and Stata.
To install `miniconda` locally on a Linux machine, follow [these instructions](https://docs.anaconda.com/miniconda/).

```bash
make venv  # create environment for running R, Python, Stata scripts
conda env config vars set PROJECT=/path/to/project # set the project path in conda
conda env config vars set STATA_DIR=/path/to/stata # set the path to Stata in conda
```

Sometimes there is an issue with `ivreghdfe` (usually throws a "last estimates not found" error); resolve it by re-running the installation commands [here](https://github.com/sergiocorreia/ivreghdfe).

Some R deps require CMake. Local user download:
```bash
# https://pachterlab.github.io/kallisto/local_build.html
wget https://github.com/Kitware/CMake/releases/download/v3.29.2/cmake-3.29.2.tar.gz
tar -xf cmake*.tar.gz
cd cmake-3.29.2
./configure --prefix=$HOME
make
make install
cmake --version
```

### R Setup
To run R notebooks, install `renv` and run `renv::restore()`. In some environments, it may be necessary to install `stringi` with conda: `conda install r-stringi`.

## Repository Structure
The replication package is organized around a small set of tracked directories and files:

- `data/` - shared inputs used across studies, including study metadata and supporting tables.
- `studies/` - one subdirectory per replication study.
  - `study.py` - the study-specific Python wrapper.
  - `README.md` - study-specific replication notes and setup details.
  - `Makefile` - commands to prepare inputs and run the study replication.
  - `expected-results.json` - the expected results (copied from the paper) used for validating the replication.
  - `results/` - study output files generated by the replication.
  - `source/` - the study's extracted source code and data, when needed.
  - Some studies also include files such as `replicate.R` and `replication.Rmd` when the original workflow uses them.
- `results/` - generated replication outputs and summary tables, including one folder per study.
  - `experiments/` - databases containing records from main experiments.
- `R/` - shared R code used by multiple studies and analysis workflows.
  - `analysis.R` - shared analysis helpers used to run and combine replication outputs.
  - `data.R` - data-loading and data-preparation helpers.
  - `plots.R` - plotting helpers for paper figures and diagnostics.
  - `utils.R` - general-purpose helper functions used across the R codebase, including data variable descriptions.
  - `reporting.R` - code for formatting and exporting numerical results to LaTeX.
  - `overimputation.R` - EXPERIMENTAL: overimputation utilities used by the imputation workflows.
  - `overimpute.R` - EXPERIMENTAL: higher-level overimputation orchestration and wrappers.
- `notebooks/` - analysis notebooks.
  - `analysis.Rmd`
- `scripts/` - helper scripts for maintenance tasks such as refreshing citations.
- `stata/` - Stata installation and support files used to run replications.
- `simulate_privacy/` - the Python package that implements the replication and simulation logic.
  - `__init__.py` - package entry point and shared exports.
  - `api.py` - public API surface for running replications and experiments.
  - `experiment.py` - experiment execution and result aggregation logic.
  - `studies.py` - protocol for replicating studies, including noise addition.
  - `mechanisms.py` - noise addition mechanisms, including differential privacy and data error.
  - `analysis.py` - schemas for storing and analyzing replication results.
  - `config.py` - configuration loading and environment-specific settings.
  - `unittest/` - automated tests.