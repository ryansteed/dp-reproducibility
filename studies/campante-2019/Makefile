include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results
	
	cd source
	for i in "AEJApplied_ConflictRegressions" \
		"AEJApplied_CrossCountryRegressions" ; \
	do \
		bash $(PROJECT)/stata/statab.sh $$i.do; \
	done
