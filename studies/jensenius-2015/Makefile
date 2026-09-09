include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results

	cd source/AEJApp-2014-0201_Dataset
	mkdir -p Figures
	Rscript Code_replication.R
