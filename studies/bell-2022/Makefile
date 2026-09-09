include ../utils.mk

source:
	unzip -d source/ source.zip
	mv source/Do\ Files source/do_files
	mv source/do_files/Table\ 6.do source/do_files/Table6.do
	mv source/do_files/Table\ 7.do source/do_files/Table7.do

results:
	mkdir -p results
	
	cd source
	for i in "Do Files/Table 3.do" ; \
		# "Do Files/Table 6.do" ; \
	do \
		bash $(PROJECT)/stata/statab.sh "$$i"; \
	done
