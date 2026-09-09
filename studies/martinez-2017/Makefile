include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results
	
	cd source/AEJApp-2015-0447_Dataset
	for i in "VHeduc_Do"; \
	# 	"dofile2" ; \
	do \
	 	bash $(PROJECT)/stata/statab.sh $$i.do; \
	done
