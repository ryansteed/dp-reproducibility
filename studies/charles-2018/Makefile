include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results
	
	cd source/chn_housing_booms_and_college
	# skipping build.do
	for i in \
		"main" ; \
	do \
		bash $(PROJECT)/stata/statab.sh $$i.do; \
	done
