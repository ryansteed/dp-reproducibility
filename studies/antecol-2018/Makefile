include ../utils.mk

source:
	unzip -d source/ source.zip
	mkdir -p source/data/output
results:
	mkdir -p results
	
	cd source/data
	for i in "aer_regressions"; \
	# 	"dofile2" ; \
	do \
		bash $(PROJECT)/stata/statab.sh $$i.do; \
	done
