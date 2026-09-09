include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results
	
	cd source/Data_20110196
	for i in "dofile_fertility_20110196"; \
	#	"dofile_hbs_20110196" \
	#	"dofile_lfs_20110196" ; \
	do \
		bash $(PROJECT)/stata/statab.sh $$i.do; \
	done
