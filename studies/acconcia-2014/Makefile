include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results
	
	cd source/data
	for i in "ACCOSI_AER_STATA_PROGRAM_MAFIA_PUBLIC_SPENDING" \
	#	"dofile2" ; \
	do \
		bash $(PROJECT)/stata/statab.sh $$i.do; \
	done
