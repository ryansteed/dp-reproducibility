include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results
	
	cd source
	for i in "Table2_3" \
		"Table4" \
		"Table5"; \
	do \
		bash $(PROJECT)/stata/statab.sh $$i.do; \
	done

	# cd source
	# for i in "dofile1" \
	# 	"dofile2" ; \
	# do \
	# 	bash $(PROJECT)/stata/statab.sh $$i.do; \
	# done
