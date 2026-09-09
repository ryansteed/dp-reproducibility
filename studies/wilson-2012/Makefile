include ../utils.mk

source:
	unzip source.zip
	mv ARRAPaper/ source/

results:
	mkdir -p results
	cd source
	bash $(PROJECT)/stata/statab.sh Wilson_AEJEP_2012.do 
