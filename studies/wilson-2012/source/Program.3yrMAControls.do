
	
***********************************************************************
* Make a three-year moving (trailing) average of real GSP per capita. *
***********************************************************************

	tsset state time
	generate RGSP_Percap = RealGSP_TO/(StatePopulation*1000)
	label variable RGSP_Percap "Millions of GSP (chained 2005) per thousand people"
	generate RealGSP_3yrMADifference = (RGSP_Percap + L12.RGSP_Percap + L24.RGSP_Percap)/3 - (L12.RGSP_Percap + L24.RGSP_Percap + L36.RGSP_Percap)/3 if time == ym(2006,12)
	bysort state: egen nonmissing_control = min(RealGSP_3yrMADifference)
	drop RealGSP_3yrMADifference
	rename nonmissing_control RealGSP_3yrMADifference

	label variable RealGSP_3yrMADifference "Difference between 2006 and 2005, trailing 3-year MA of Real GSP per capita"

**********************************************************************
* Make a three-year moving (trailing) average of real PI per capita. *
**********************************************************************

	cap drop StatePI_cap
	gen StatePI_cap = StatePI/(StatePopulation*1000)

	cap drop AnnualStatePI_cap
	gen AnnualStatePI_cap = AnnualStatePI/(StatePopulation*1000)
	
	tsset state time
	generate RealPI_3yrMADifference = (StatePI_cap + L12.StatePI_cap + L24.StatePI_cap)/3 - (L12.StatePI_cap + L24.StatePI_cap + L36.StatePI_cap)/3 if time == ym(2006,1)
	bysort state: egen nonmissing_control = min(RealPI_3yrMADifference)
	drop RealPI_3yrMADifference
	rename nonmissing_control RealPI3yrMADifference
	label variable RealPI3yrMADifference "Difference between 2006 and 2005, trailing 3-year MA of Real PI per capita"


	generate RealAnnualPI_3yrMADifference = (AnnualStatePI_cap + L12.AnnualStatePI_cap + L24.AnnualStatePI_cap)/3 - (L12.AnnualStatePI_cap + L24.AnnualStatePI_cap + L36.AnnualStatePI_cap)/3 if time == ym(2006,1)
	bysort state: egen nonmissing_control = min(RealAnnualPI_3yrMADifference)
	drop RealAnnualPI_3yrMADifference
	rename nonmissing_control RealAnnualPI_3yrMADifference
	label variable RealPI3yrMADifference "Difference between 2006 and 2005, trailing 3-year MA of Real PI per capita"
	
	label variable RealAnnualPI_3yrMADifference "Difference between 2006 and 2005, trailing 3-year MA of Annual Real PI per capita"
	