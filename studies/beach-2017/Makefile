include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results
	
	cd source/POL2015-0394_data
	for i in "Main-results" \
		"Table-7" ; \
	do \
		bash $(PROJECT)/stata/statab.sh $$i.do; \
	done
