include ../utils.mk

source:
	unzip -d source/ source.zip
	unzip -d source/replication/ source/replication.zip
results:
	mkdir -p results
	
	cd source/replication/Do
	for i in "5_analysis"; \
	# 	"dofile2" ; \
	do \
		bash $(PROJECT)/stata/statab.sh $$i.do; \
	done
