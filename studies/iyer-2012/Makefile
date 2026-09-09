include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results
	
	cd source/20110220_IMMT_ReplicationData
	for i in "IMMT_20110220"; \
	do \
		bash $(PROJECT)/stata/statab.sh $$i.do; \
	done
	
	# cd source
	# for i in "dofile1" \
	# 	"dofile2" ; \
	# do \
	# 	bash $(PROJECT)/stata/statab.sh $$i.do; \
	# done
