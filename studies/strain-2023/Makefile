include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results
	cd source/'ICPSR replication package v3'/'Economic Inquiry Replication'/
		
	bash $(PROJECT)/stata/statab.sh code/00-master.do;

	# for i in "dofile1" \
	# 	"dofile2" ; \
	# do \
	# 	bash $(PROJECT)/stata/statab.sh $$i.do; \
	# done
