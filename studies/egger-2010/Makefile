include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results
	
	cd source/Data
	for i in "EggerKoethenbuerger_AEJ_results_27May2010"; \
	# 	"dofile2" ; \
	do \
		bash $(PROJECT)/stata/statab.sh $$i.do; \
	done
