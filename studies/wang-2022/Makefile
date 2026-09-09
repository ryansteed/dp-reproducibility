include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results
	
	cd source/"Import competition and the gender employment gap in China_Replication files"
	bash $(PROJECT)/stata/statab.sh dofiles/tables.do
	# for i in "dofile1" \
	# 	"dofile2" ; \
	# do \
	# 	bash $(PROJECT)/stata/statab.sh $$i.do; \
	# done
