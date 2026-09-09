include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results
	
	cd source/replication
	for i in "results" ; \
	do \
		bash $(PROJECT)/stata/statab.sh $$i.do; \
	done
