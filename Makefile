.ONESHELL:
.PHONY: sync alias citations source-from-scratch

VENV_NAME?=venv
CONDA_ACTIVATE = source $$(conda info --base)/etc/profile.d/conda.sh ; conda activate ; conda activate

venv:
	conda env create -f environment.yml --prefix ./venv
	./stata/install.sh

update: venv
	conda env update -f environment.yml --prefix ./venv --prune
	./stata/install.sh

make citations:
	python scripts/refresh_citations.py data/studies.csv

make source-from-scratch:
	echo "Creating source for $(study) from scratch"
	cd studies/$(study) && rm -rf source && make source

clear-tmp:
	rm -rf studies/tmp_*

replication_package.zip: 
	git archive -v HEAD . \
		":(exclude)notebooks/*.ipynb" \
		":(exclude).gitattributes" \
		":(exclude).gitignore" \
		":(exclude).lintr" \
		":(exclude).renvignore" \
		":(exclude)results/experiments/archive" \
		":(exclude)R/evans_king_2023" \
		-o replication_package.zip
