


clear*
use "$pathdata/data_spillovers_censo.dta", clear


xtset AMC time
keep if cod_uf>40
drop if cod_uf==53
keep if year==2010
tab basin, gen(basin_)
tab cod_uf, gen(cod_uf_)


****************************************************************************************************
**** Table Bustos et al                                                                                    
****************************************************************************************************


global controlsBustos "baseline_share_poprural baseline_share_analf baseline_incomepc baseline_lpopdensity"


foreach i in ds_areasoy dLa_L dLm_L migration_rate {

reg `i'  dpotentialAMC $controlsBustos, cluster(basin)
	outreg2 using "$pathresults/tabE6_SpilloverBustos.xls",  aster(se) dec(3) label nocons keep(dpotentialAMC) addtext(Controls, Bustos, State FE, No, SE, Cluster)	
	
reg `i'  dpotentialAMC dpotentialUpstream $controlsBustos, cluster(basin)
	outreg2 using "$pathresults/tabE6_SpilloverBustos.xls",  aster(se) dec(3) label nocons keep(dpotentialAMC dpotentialUpstream) addtext(Controls, Bustos, State FE, No, SE, Cluster)
	
}		

****************************************************************************************************
**** Table Bustos et al specification + our controls                                                                                  
****************************************************************************************************


global controlsBustosOurs "baseline_share_poprural baseline_share_analf baseline_incomepc baseline_lpopdensity dcoverage_psf dl_hospbedspc dcoverage_pbf dhospital"


foreach i in ds_areasoy dLa_L dLm_L migration_rate {

areg `i'  dpotentialAMC $controlsBustosOurs, cluster(basin) abs(cod_uf)
	outreg2 using "$pathresults/tabE6_SpilloverBustosOurs.xls",  aster(se) dec(3) label nocons keep(dpotentialAMC) addtext(Controls, Bustos+Ours, State FE, Yes, SE, Cluster)	
	
areg `i'  dpotentialAMC dpotentialUpstream $controlsBustosOurs, cluster(basin) abs(cod_uf)
	outreg2 using "$pathresults/tabE6_SpilloverBustosOurs.xls",  aster(se) dec(3) label nocons keep(dpotentialAMC dpotentialUpstream) addtext(Controls, Bustos+Ours, State FE, Yes, SE, Cluster)
		
}
*		
	
	
	
