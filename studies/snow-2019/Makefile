include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results
	
	cd source/MS20080918_data_programs/gis
	bash $(PROJECT)/stata/statab.sh cln-seggis-all.do
	bash $(PROJECT)/stata/statab.sh cln-seggisx.do
	cd ../programs
	bash $(PROJECT)/stata/statab.sh build-districts.do
	bash $(PROJECT)/stata/statab.sh panel-censusx.do
	cd ../tables
	bash $(PROJECT)/stata/statab.sh counterfact.do
	bash $(PROJECT)/stata/statab.sh tables2to5.do
	# cd source
	# for i in "dofile1" \
	# 	"dofile2" ; \
	# do \
	# 	bash $(PROJECT)/stata/statab.sh $$i.do; \
	# done
