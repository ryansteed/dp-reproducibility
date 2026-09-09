include ../utils.mk

source:
	unzip -d source/ source.zip
	mv "source/CC Funding Project_AERA Open.do" source/dofile.do
results:
	mkdir -p results
	
	cd source
	for i in "dofile"; \
	# 	"dofile2" ; \
	do \
		bash $(PROJECT)/stata/statab.sh $$i.do; \
	done
