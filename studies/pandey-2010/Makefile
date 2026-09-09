include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results
	
	 cd source/data-files
	 for i in "table-4" \
	 	"table-5" ; \
	 do \
	 	bash $(PROJECT)/stata/statab.sh $$i.do; \
	 done
