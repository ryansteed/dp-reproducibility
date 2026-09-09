include ../utils.mk

source:
	unzip -d source/ source.zip
	mv 'source/replicate/programs/Figure 1, A1 Table 2, 3.do' source/replicate/programs/table3.do
results:
	mkdir -p results
	
	cd source/replicate/programs
	for i in "table3"; \
	# 	"dofile2" ; \
	do \
		bash $(PROJECT)/stata/statab.sh $$i.do; \
	done
