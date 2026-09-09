include ../utils.mk

source:
	unzip -d source/ source.zip
	mv source/SRDS/Germancities/RemotenessAER source/
results:
	mkdir -p results
	
	cd source/RemotenessAER
	for i in "regressions/main_results/main_results"; \
	# 	"dofile2" ; \
	do \
		bash $(PROJECT)/stata/statab.sh $$i.do; \
	done
