include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results
	
	cd source/1033-Project
	for i in "analysis";
	do \
	 	bash $(PROJECT)/stata/statab.sh $$i.do; \
	done
