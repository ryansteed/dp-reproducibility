include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results
	
	cd source/AERPP-Replication-Data
	for i in "LeeLucaOwensSharma_AER_PP"; \
	do \
		bash $(PROJECT)/stata/statab.sh $$i.do; \
	done
