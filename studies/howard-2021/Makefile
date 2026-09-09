include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results
	
	cd source/dofiles
	for i in "master"; \
	# 	"dofile2" ; \
	do \
		bash $(PROJECT)/stata/statab.sh $$i.do; \
	done
