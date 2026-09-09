include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results
	
	cd source/AER_Political_Resource_Curse_DATA
	for i in "PRC_AER_Tab5" \
		"PRC_AER_Tab9"; \
	do \
		bash $(PROJECT)/stata/statab.sh $$i.do; \
	done
