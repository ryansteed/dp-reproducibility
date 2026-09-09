********************************************************************************
* Land Use

scalar first_reg=1 // to use replace in the outreg inside the loop below
		
foreach y in Forest NatNonForest Farming Agriculture Pasture AgricOrPast{
	
xi: xtreg share_area`y' potentialAMC int_uf* $controls_landuse, fe cluster(basin)
	
	if first_reg==1{
		sum share_area`y' if share_area`y'!=. & year==2000
		eret2 scalar y_mean_baseline=r(mean)
		eret2 scalar y_sd_baseline=r(sd)
		outreg2 using "$pathresults/$table_soil_use", ctitle("`y' area") aster(se) e(y_mean_baseline y_sd_baseline) dec(3) label nocons keep(potentialAMC) addtext(UF-Year FE, Yes, Controls, Yes) replace 
		scalar first_reg=0
	}
	else{
		sum share_area`y' if share_area`y'!=. & year==2000
		eret2 scalar y_mean_baseline=r(mean)
		eret2 scalar y_sd_baseline=r(sd)
		outreg2 using "$pathresults/$table_soil_use", ctitle("`y' area") aster(se) e(y_mean_baseline y_sd_baseline) dec(3) label nocons keep(potentialAMC) addtext(UF-Year FE, Yes, Controls, Yes) append
	}
}
