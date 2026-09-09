include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results
	cd source/APP2016-0008_data
	bash $(PROJECT)/stata/statab.sh deaths_aejfinal.do;
	# cd source
	# for i in "dofile1" \
	# 	"dofile2" ; \
	# do \
	# 	bash $(PROJECT)/stata/statab.sh $$i.do; \
	# done
