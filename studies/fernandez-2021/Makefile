include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results
	cd source
	bash $(PROJECT)/stata/statab.sh AEA_PP_do_file.do;
	# cd source
	# for i in "dofile1" \
	# 	"dofile2" ; \
	# do \
	# 	bash $(PROJECT)/stata/statab.sh $$i.do; \
	# done
