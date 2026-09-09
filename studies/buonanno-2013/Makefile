include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results
	
	cd source/20111641_data
	for i in "figure1andpanelboftable2" \
		"table1figure2" \
		"table2andinputefortables3_4and5" \
		"table7and8" ; \
	do \
		bash $(PROJECT)/stata/statab.sh $$i.do; \
	done
