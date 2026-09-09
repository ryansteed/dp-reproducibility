********************************************************************************
* Robustness Checks -- Trends
*
* Outcomes: Birth Rate & IMR
local flag=0

foreach y in birth_rate IMR{
xi: xtreg `y' $instr $control_trendSocioecon, fe cluster(basin)
	sum `y' if year==2000
	eret2 scalar y_baseline_mean=r(mean)
	
	if `flag'==0{
		outreg2 using "$pathresults/$table_trends", ctitle("`y', Reduced Form") aster(se) dec(3) label nocons e(y_baseline_mean) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes, Baseline Birth Rate Trend, No, Baseline SES Trends, Yes) keep($instr) replace
	}
	else{
		outreg2 using "$pathresults/$table_trends", ctitle("`y', Reduced Form") aster(se) dec(3) label nocons e(y_baseline_mean) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes, Baseline Birth Rate Trend, No, Baseline SES Trends, Yes) keep($instr)
	}

local flag=1	
	
xi: xtreg `y' $instr $control_trendSocioeconBirth, fe cluster(basin)
	sum `y' if year==2000
	eret2 scalar y_baseline_mean=r(mean)
	outreg2 using "$pathresults/$table_trends", ctitle("`y', Reduced Form") aster(se) dec(3) label nocons e(y_baseline_mean) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes, Baseline Birth Rate Trend, Yes, Baseline SES Trends, Yes) keep($instr)

xi: xtivreg2 `y' ($glyph_up=$instr) $control_trendSocioecon, fe cluster(basin) partial(int_uf*)
	sum `y' if year==2000
	eret2 scalar y_baseline_mean=r(mean)
	mat b=e(b)
	mat v=e(V)
	scalar tstat2 = (b[1,1]/sqrt(v[1,1]))^2
	scalar rejrate_Leeetal = 1 - normal(sqrt(`e(widstat)'*tstat2)/(sqrt(`e(widstat)')+sqrt(tstat2))) + normal((-sqrt(`e(widstat)'*tstat2)-2*`e(widstat)')/(sqrt(`e(widstat)')+sqrt(tstat2)))
	outreg2 using "$pathresults/$table_trends", ctitle("`y', IV") aster(se) dec(3) label nocons e(y_baseline_mean) nor2 addstat(F-stat, `e(widstat)', Rejection Rate (Lee et al. 2020), rejrate_Leeetal) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes, Baseline Birth Rate Trend, No, Baseline SES Trends, Yes) keep($glyph_up) 	
	
xi: xtivreg2 `y' ($glyph_up=$instr) $control_trendSocioeconBirth, fe cluster(basin) partial(int_uf*)
	sum `y' if year==2000
	eret2 scalar y_baseline_mean=r(mean)
	mat b=e(b)
	mat v=e(V)
	scalar tstat2 = (b[1,1]/sqrt(v[1,1]))^2
	scalar rejrate_Leeetal = 1 - normal(sqrt(`e(widstat)'*tstat2)/(sqrt(`e(widstat)')+sqrt(tstat2))) + normal((-sqrt(`e(widstat)'*tstat2)-2*`e(widstat)')/(sqrt(`e(widstat)')+sqrt(tstat2)))
	outreg2 using "$pathresults/$table_trends", ctitle("`y', IV") aster(se) dec(3) label nocons e(y_baseline_mean) nor2 addstat(F-stat, `e(widstat)', Rejection Rate (Lee et al. 2020), rejrate_Leeetal) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes, Baseline Birth Rate Trend, Yes, Baseline SES Trends, Yes) keep($glyph_up) 
}


* Other Outcomes
local flag=0

foreach y in r_baby_death_24hs r_baby_death_27days r_baby_death_year r_baby_death_infectious r_baby_death_respiratory r_baby_death_perinatal r_baby_death_congenital r_baby_death_external r_baby_death_endoc_nut r_baby_death_genito r_baby_death_illdef r_baby_death_others FMR s_birth_lowbirthw s_birth_weekspreg_37plus s_gesta_preterm s_gesta_below22 s_gesta_22_27 s_gesta_28_36 s_gesta_37_41 s_gesta_above42 s_lowapgar1 s_lowapgar5 IMR_masc IMR_fem sex_ratio l_births birth_rate birth_motheredclow_mean birth_motheredcmid_mean birth_motheredchigh_mean birth_motherage_mean{

xi: xtivreg2 `y' ($glyph_up=$instr) $control_trendSocioeconBirth, fe cluster(basin) partial(int_uf*)
	sum `y' if year==2000
	eret2 scalar y_baseline_mean=r(mean)
	mat b=e(b)
	mat v=e(V)
	scalar tstat2 = (b[1,1]/sqrt(v[1,1]))^2
	scalar rejrate_Leeetal = 1 - normal(sqrt(`e(widstat)'*tstat2)/(sqrt(`e(widstat)')+sqrt(tstat2))) + normal((-sqrt(`e(widstat)'*tstat2)-2*`e(widstat)')/(sqrt(`e(widstat)')+sqrt(tstat2)))
	
	if `flag'==0{
		outreg2 using "$pathresults/$table_other_trends", ctitle("`y', IV") aster(se) dec(3) label nocons e(y_baseline_mean) nor2 addstat(F-stat, `e(widstat)', Rejection Rate (Lee et al. 2020), rejrate_Leeetal) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes, Baseline Birth Rate Trend, Yes, Baseline SES Trends, Yes) keep($glyph_up) replace
	}
	else{
		outreg2 using "$pathresults/$table_other_trends", ctitle("`y', IV") aster(se) dec(3) label nocons e(y_baseline_mean) nor2 addstat(F-stat, `e(widstat)', Rejection Rate (Lee et al. 2020), rejrate_Leeetal) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes, Baseline Birth Rate Trend, Yes, Baseline SES Trends, Yes) keep($glyph_up)
	}
	local flag=1
}
