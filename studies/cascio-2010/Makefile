include ../utils.mk

source:
	unzip source.zip
	mv data_AEJPol-2010-0239/ source/

results:
	mkdir -p results
	bash $(PROJECT)/stata/statab.sh source/analysis_all.do
