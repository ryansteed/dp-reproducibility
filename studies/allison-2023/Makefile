include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results
	
	cd source/Replication_JEEA
	bash $(PROJECT)/stata/statab.sh ./Code/0_Main.do
	# cd source
	# for i in "dofile1" \
	# 	"dofile2" ; \
	# do \
	# 	bash $(PROJECT)/stata/statab.sh $$i.do; \
	# done
