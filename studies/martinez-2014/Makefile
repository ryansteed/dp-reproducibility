include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results
	
	cd source/AER-2011-1027.R2_Data
	bash $(PROJECT)/stata/statab.sh LocalOfficials_AER.do
