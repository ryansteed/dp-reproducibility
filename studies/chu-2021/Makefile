include ../utils.mk

source:
	unzip -d source/ source.zip
	mkdir source/tables
results:
	mkdir -p results
	
	cd source
	for i in "AEJ_do"; \
	# 	"dofile2" ; \
	do \
		bash $(PROJECT)/stata/statab.sh $$i.do; \
	done
