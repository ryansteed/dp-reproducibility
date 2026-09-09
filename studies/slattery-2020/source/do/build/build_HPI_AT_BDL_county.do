/*******************************************************************************
Project:		Evaluating State and Local Business Tax Incentives (JEP)
					Slattery and Zidar
File created:	12/28/2019
Last modified: 	12/28/2019
Modified by:	Dustin Swonder
Description:	This file builds a .dta file from the HPI_AT_BDL.xlsx 
				spreadsheet retrieved from https://www.fhfa.gov/DataTools/
				Downloads/Documents/HPI/HPI_AT_BDL_county.xlsx on July 29,
				2019.
*******************************************************************************/

import excel using $rawdir/HPI_AT_BDL_county.xlsx, firstrow cellrange(A7) clear
drop AnnualChange HPI HPIwith1990base State County

/* In original data, HPIwith2000base is coded as "." if FHFA is not able to get 
	data for county */
destring HPIwith2000base, generate(HPIwith2000base_tmp)
assert HPIwith2000base == "." if missing(HPIwith2000base_tmp)
drop HPIwith2000base

destring Year FIPScode, replace

rename (Year FIPScode HPIwith2000base_tmp) (year fipscounty HPI)

gen ln_HPI = log(HPI)

sort fipscounty year

save $processeddir/HPI_AT_BDL_county.dta, replace