include ../utils.mk

source:
	unzip -d source/ source.zip
	echo "After updating code, also run make intermediate to create correct data file."

intermediate:
	cd source/AEJ-Replication
	bash $(PROJECT)/stata/statab.sh Data_Setup.do

results:
	mkdir -p results
	
	cd source/AEJ-Replication
	# abbreviated data setup, custom
	for i in "Data_Setup_abbrv" \
		"Main-Results-Tables" ; \
	do \
		bash $(PROJECT)/stata/statab.sh $$i.do; \
	done
