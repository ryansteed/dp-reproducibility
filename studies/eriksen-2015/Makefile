include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results
	
	cd source/data
	for i in "AEJ_Regression_Program-6-24-14"; \
	# 	"dofile2" ; \
	do \
		bash $(PROJECT)/stata/statab.sh $$i.do; \
	done
