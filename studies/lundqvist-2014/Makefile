include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results
	
	cd source/ReplicationData
	for i in "create_data" \
		"estimations" ; \
	do \
		bash $(PROJECT)/stata/statab.sh $$i.do; \
	done
