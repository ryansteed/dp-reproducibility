include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results
	
	cd "source/Replication/Do Files"
	for i in "onestep_tables"; \
	# 	"dofile2" ; \
	do \
		bash $(PROJECT)/stata/statab.sh $$i.do; \
	done
