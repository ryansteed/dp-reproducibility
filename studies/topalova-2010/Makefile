include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results
	
	cd source/_data
	for i in "Tables"; \
	do \
		bash $(PROJECT)/stata/statab.sh $$i.do; \
	done
