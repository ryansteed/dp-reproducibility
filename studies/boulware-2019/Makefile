include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results
	
	cd source/data
	for i in "bk-panel-replication" \
		"bk-cross-section-replication" ; \
	do \
		bash $(PROJECT)/stata/statab.sh $$i.do; \
	done
