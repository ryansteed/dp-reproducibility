include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results
	
	cd source/P2014_1138_data
	for i in "MMS_MA_analysis";
	do \
	 	bash $(PROJECT)/stata/statab.sh $$i.do; \
	done
