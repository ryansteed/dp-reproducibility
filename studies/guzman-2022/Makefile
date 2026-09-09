include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results
	
	cd source/CovidAndEthnicDivision_Replication
	for i in Create_Tables_CovidEthnicDivision; \
	do \
		bash $(PROJECT)/stata/statab.sh $$i.do; \
	done
