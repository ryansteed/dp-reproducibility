include ../utils.mk

source:
	unzip -d source/ source.zip

results:
	mkdir -p results
	
	cd source/Williams_files
	# per readme, setup is executed first, then POP, then the rest of the cleaning files, then createmain, then maindo
	# there are other results files, but we may not need them — see README
	for i in "Cleaning_files/Setup_file" \
		"Cleaning_files/POP_1840" \
		"Cleaning_files/POP_1860" \
		"Cleaning_files/POP_1900" \
		"Cleaning_files/POP_1910" \
		"Cleaning_files/POP_1920" \
		"Cleaning_files/POP_1930" \
		"Cleaning_files/POP_2010" \
		"Cleaning_files/Censusage" \
		"Cleaning_files/Censuseducation" \
		"Cleaning_files/Illiterate" \
		"Cleaning_files/Lynching" \
		"Cleaning_files/Lynchingallstates" \
		"Cleaning_files/Marital" \
		"Cleaning_files/News" \
		"Cleaning_files/Numslaves" \
		"Cleaning_files/Proact" \
		"Cleaning_files/Religion" \
		"Cleaning_files/SFP93" \
		"Cleaning_files/Votingage" \
		"Results_inpaper/Createmain" \
		"Results_inpaper/Maindo" \
		; \
	do \
		bash $(PROJECT)/stata/statab.sh $$i.do; \
	done
