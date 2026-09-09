include ../utils.mk

source:
	unzip source.zip
	mv Replication/ source/
	mkdir source/Output/bs
	mv "source/programs/02 - Paper_exhibits_BS_SEs.do" source/programs/Paper_exhibits_BS_SEs.do

results:
	mkdir -p results
	bash $(PROJECT)/stata/statab.sh source/programs/Paper_exhibits_BS_SEs.do
