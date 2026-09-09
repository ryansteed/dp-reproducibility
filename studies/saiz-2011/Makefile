include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results
	cd source/DATAAEJPOL2009-0191/
	bash $(PROJECT)/stata/statab.sh AEJPOLICY-MS2009-0191.do
	# cd source
	# for i in "dofile1" \
	# 	"dofile2" ; \
	# do \
	# 	bash $(PROJECT)/stata/statab.sh $$i.do; \
	# done
