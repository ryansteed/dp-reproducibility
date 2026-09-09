include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results
	cd source/Stata-do-files
	bash $(PROJECT)/stata/statab.sh sosina-weathers_main.do;
	
	# cd source
	# for i in "dofile1" \
	# 	"dofile2" ; \
	# do \
	# 	bash $(PROJECT)/stata/statab.sh $$i.do; \
	# done
