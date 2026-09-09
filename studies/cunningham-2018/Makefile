include ../utils.mk

source:
	unzip -d source/ source.zip
	unzip source/P2018_1110_data/AEAPP_data.zip -d source/
	unzip source/P2018_1110_data/AEAPP_dofile.zip -d source/

results:
	mkdir -p results
	
	cd source/dofile
	for i in "master_AEAPP"; \
	# 	"dofile2" ; \
	do \
		bash $(PROJECT)/stata/statab.sh $$i.do; \
	done
