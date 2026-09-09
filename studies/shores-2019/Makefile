include ../utils.mk

source:
	unzip -d source/ source.zip
	mv "AERA OPEN PROGRAM TABLES FIGURES.do" dofile.do
results:
	mkdir -p results
	
	cd source
	for i in "dofile"; \
	# 	"dofile2" ; \
	do \
		bash $(PROJECT)/stata/statab.sh $$i.do; \
	done
