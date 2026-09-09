*************************************************************
**********Coomunity College Funding Project******************
*************************************************************
clear

*** EDIT by Donna
version 13

*** EDIT by Donna: To solve the problem: Fixed width strings in Stata .dta files are limited to 244 (or fewer)
*** characters.  Column 'x_total_budgeted' does not satisfy this restriction. Use the
*** 'version=117' parameter to write the newer (Stata 13 and later) format.
/*
use "cc local funding_AERA Open.dta", clear
replace x_total_budgeted = substr(x_total_budgeted, 1, 244)
compress

replace x_state_gen_fund_budgeted = substr(x_state_gen_fund_budgeted, 1, 244)
compress

replace x_total_state_budgeted = substr(x_total_state_budgeted, 1, 244)
compress

save new_data.dta, replace
*/

use "new_data.dta", clear

keep if twoyear==1

drop if local_pct ==.

*Drop special focus colleges*

drop if carnegie == 10
drop if carnegie == 11
drop if carnegie == 12
drop if carnegie == 13

*Create rural indicator*

gen rural = 0
replace rural = 1 if locale ==6

*log of total revenue*

gen ln_total_adj = ln(total_adj)

*Creating total revenue per FTE variable*

gen total_fte_adj = (total_adj/fteug)

gen ln_total_fte_adj = ln(total_fte_adj)

*Creating total revenue per million variable*

gen total_mil_adj = (total_adj/1000000)

gen ln_total_mil_adj = ln(total_mil_adj)

*log of state appropriations indicators*

gen ln_state_adj = ln(state_adj)
gen ln_state_fte = ln(state_fte)
gen ln_state_mil_adj = ln(state_mil_adj)

*log of local appropriations*

gen ln_local_adj = ln(local_adj)
gen ln_local_fte = ln(local_fte)
gen ln_local_mil_adj = ln(local_mil_adj)

*Creating enrollment share variables*

*Low-income student enrollment % captured by federal grant recipients: fgrnt_p*

drop if fgrnt_p ==. 
sum fgrnt_p

*Black enrollment percent*

gen black_pct = (enru12_bkaa/enru12)*100

*Asian enrollment percent*

gen anhpi_pct = (enru12_anhpi/enru12)*100

*Native American/American Indian enrollment percent*

gen aian_pct = (enru12_aian/enru12)*100

*URM student enrollment percent*

gen pct_urm_2yr=((enru12_aian+enru12_bkaa+enru12_hisp)/enru12)*100 if twoyear ==1

*Create above-average share indicators*

**Above-average share of racially minoritized students
gen high_pct_urm_2yr = 0
replace high_pct_urm_2yr = 1 if pct_urm_2yr >=26.84031

**Above-average share of low-income students
gen high_pct_fgrnt_2yr = 0
replace high_pct_fgrnt_2yr = 1 if fgrnt_p >=49.00191

***Creating a measure of PBI eligiblity by using only criteria for % of Black students and focsuing on low-income only rather than LIFG*

gen pbi_eligible = .

replace pbi_eligible = 1 if (black_pct >=40 & !mi(black_pct)) & (fgrnt_p >= 50 & !mi(fgrnt_p)) & (fteug >= 1000 & !mi(fteug))

replace pbi_eligible = 0 if pbi_eligible == . & black_pct !=.

***Creating indicator for Asian American and Native American Pacific Islander-Serving Institution eligibility

gen aanapsi_eligible = .

replace aanapsi_eligible = 1 if (anhpi_pct >= 10 & !mi(anhpi_pct))

replace aanapsi_eligible = 0 if aanapsi_eligible == . & anhpi_pct !=.

***Creating indicator for Native American-Serving Nontribal Institution eligibility

gen nasni_eligible = .

replace nasni_eligible = 1 if (aian_pct >= 10 & !mi(aian_pct))

replace nasni_eligible = 0 if nasni_eligible == . & aian_pct !=.


***Descriptives of outcomes and ind. var. - total_adj // ind. var: local_pct 

***Descriptives for Table 1***

***Local Percent***
sum local_pct
sum local_pct if local_pct >1
sum local_pct if local_pct <1

***Dependent Variables***
//Total revenue
sum total_adj
sum total_adj if local_pct >1
sum total_adj if local_pct <1

//Total revenue per FTE student
sum total_fte_adj
sum total_fte_adj if local_pct >1
sum total_fte_adj if local_pct <1


//Total revenue (millions)
sum total_mil_adj
sum total_mil_adj if local_pct >1
sum total_mil_adj if local_pct <1

***Covariates***

sum tuition2_adj
sum tuition2_adj if local_pct >1
sum tuition2_adj if local_pct <1

sum fteug
sum fteug if local_pct >1
sum fteug if local_pct <1

sum instruct_fte
sum instruct_fte if local_pct >1
sum instruct_fte if local_pct <1

sum stunemprate 
sum stunemprate if local_pct >1
sum stunemprate if local_pct <1

sum stcollage2
sum stcollage2 if local_pct >1
sum stcollage2 if local_pct <1

sum stinccap_cpi18
sum stinccap_cpi18 if local_pct >1
sum stinccap_cpi18 if local_pct <1

sum stbaabove_p
sum stbaabove_p if local_pct >1
sum stbaabove_p if local_pct <1

//College population by race

sum stcoll2_black
sum stcoll2_black if local_pct >1
sum stcoll2_black if local_pct <1

sum stcoll2_hisp
sum stcoll2_hisp if local_pct >1
sum stcoll2_hisp if local_pct <1

sum stcoll2_amind
sum stcoll2_amind if local_pct >1
sum stcoll2_amind if local_pct <1

sum stcoll2_aspac
sum stcoll2_aspac if local_pct >1
sum stcoll2_aspac if local_pct <1

//Descriptives for Table 2: outcomes across inst types

//Total revenue
sum total_adj

sum total_adj if rural == 1

sum total_adj if pbi_eligible == 1

sum total_adj if HSI_pub ==1

sum total_adj if aanapsi_eligible == 1


sum total_adj if high_pct_urm_2yr == 1

sum total_adj if high_pct_urm_2yr == 0

sum total_adj if high_pct_fgrnt_2yr == 1

sum total_adj if high_pct_fgrnt_2yr == 0

//Total revenue per FTE student

sum total_fte_adj

sum total_fte_adj if rural == 1

sum total_fte_adj if pbi_eligible == 1

sum total_fte_adj if HSI_pub ==1

sum total_fte_adj if aanapsi_eligible == 1


sum total_fte_adj if high_pct_urm_2yr == 1

sum total_fte_adj if high_pct_urm_2yr == 0

sum total_fte_adj if high_pct_fgrnt_2yr == 1

sum total_fte_adj if high_pct_fgrnt_2yr == 0

//Total revenue (millions)

sum total_mil_adj

sum total_mil_adj if rural == 1

sum total_mil_adj if pbi_eligible == 1

sum total_mil_adj if HSI_pub ==1

sum total_mil_adj if aanapsi_eligible == 1


sum total_mil_adj if high_pct_urm_2yr == 1

sum total_mil_adj if high_pct_urm_2yr == 0

sum total_mil_adj if high_pct_fgrnt_2yr == 1

sum total_mil_adj if high_pct_fgrnt_2yr == 0

//Descriptives of local pct across inst types

sum local_pct

sum local_pct if rural == 1

sum local_pct if pbi_eligible == 1

sum local_pct if HSI_pub ==1

sum local_pct if aanapsi_eligible == 1


sum local_pct if high_pct_urm_2yr == 1

sum local_pct if high_pct_urm_2yr == 0

sum local_pct if high_pct_fgrnt_2yr == 1

sum local_pct if high_pct_fgrnt_2yr == 0


// Covariates
local covariates "ln_tuition2 ln_fteug ln_instruct_fte ln_stinccap stunemprate stbaabove_p ln_stcollage2 stcoll2_black_p stcoll2_hisp_p stcoll2_amind_p"


********************************************************************
*********Variations of (Logged) Total Revenue as Outcome************
********************************************************************


*Code below produces results included in Tables 3, 4, and A1 

//All CCs

foreach y in total_adj ln_total_adj total_fte_adj ln_total_fte_adj total_mil_adj ln_total_mil_adj {
reghdfe `y' local_pct, absorb(unitid year) cl(unitid)
* outreg2 using "D:\Gates CC Project\Output\localpct_all.xml", excel dec(3) alpha(0.001, 0.01, 0.05) symbol(***, **, *) ctitle(`y')  addstat(Adjusted within R-squared, `e(r2_a_within)') addtext(Covariates, NO, College FE, YES, Year FE, YES)

reghdfe `y' local_pct `covariates', absorb(unitid year) cl(unitid)
* outreg2 using "D:\Gates CC Project\Output\localpct_all.xml", excel dec(3) alpha(0.001, 0.01, 0.05) symbol(***, **, *) ctitle(`y')  addstat(Adjusted within R-squared, `e(r2_a_within)') addtext(Covariates, YES, College FE, YES, Year FE, YES)
} 

//Rural CCs

foreach y in total_adj ln_total_adj total_fte_adj ln_total_fte_adj total_mil_adj ln_total_mil_adj {
reghdfe `y' local_pct if rural == 1, absorb(unitid year) cl(unitid)
* outreg2 using "D:\Gates CC Project\Output\localpct_rural.xml", excel dec(3) alpha(0.001, 0.01, 0.05) symbol(***, **, *) ctitle(`y')  addstat(Adjusted within R-squared, `e(r2_a_within)') addtext(Covariates, NO, College FE, YES, Year FE, YES)

reghdfe `y' local_pct `covariates' if rural == 1, absorb(unitid year) cl(unitid)
* outreg2 using "D:\Gates CC Project\Output\localpct_rural.xml", excel dec(3) alpha(0.001, 0.01, 0.05) symbol(***, **, *) ctitle(`y')  addstat(Adjusted within R-squared, `e(r2_a_within)') addtext(Covariates, YES, College FE, YES, Year FE, YES)
}

*** EDITED by Donna
eststo:reghdfe ln_total_adj local_pct `covariates', absorb(unitid year) cl(unitid)
eststo:reghdfe ln_total_adj local_pct `covariates' if rural == 1, absorb(unitid year) cl(unitid)
estout using "../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
//PBI-eligible CCs

foreach y in total_adj ln_total_adj total_fte_adj ln_total_fte_adj total_mil_adj ln_total_mil_adj {
reghdfe `y' local_pct if pbi_eligible == 1, absorb(unitid year) cl(unitid)
outreg2 using "D:\Gates CC Project\Output\localpct_PBI.xml", excel dec(3) alpha(0.001, 0.01, 0.05) symbol(***, **, *) ctitle(`y')  addstat(Adjusted within R-squared, `e(r2_a_within)') addtext(Covariates, NO, College FE, YES, Year FE, YES)

reghdfe `y' local_pct `covariates' if pbi_eligible == 1, absorb(unitid year) cl(unitid)
outreg2 using "D:\Gates CC Project\Output\localpct_PBI.xml", excel dec(3) alpha(0.001, 0.01, 0.05) symbol(***, **, *) ctitle(`y')  addstat(Adjusted within R-squared, `e(r2_a_within)') addtext(Covariates, YES, College FE, YES, Year FE, YES)
}

//HSI CCs

foreach y in total_adj ln_total_adj total_fte_adj ln_total_fte_adj total_mil_adj ln_total_mil_adj {
reghdfe `y' local_pct if HSI_pub == 1, absorb(unitid year) cl(unitid)
outreg2 using "D:\Gates CC Project\Output\localpct_HSI.xml", excel dec(3) alpha(0.001, 0.01, 0.05) symbol(***, **, *) ctitle(`y')  addstat(Adjusted within R-squared, `e(r2_a_within)') addtext(Covariates, NO, College FE, YES, Year FE, YES)

reghdfe `y' local_pct `covariates' if HSI_pub == 1, absorb(unitid year) cl(unitid)
outreg2 using "D:\Gates CC Project\Output\localpct_HSI.xml", excel dec(3) alpha(0.001, 0.01, 0.05) symbol(***, **, *) ctitle(`y')  addstat(Adjusted within R-squared, `e(r2_a_within)') addtext(Covariates, YES, College FE, YES, Year FE, YES)
}

***Checking to see if CA is driving HSI finding***

foreach y in total_adj ln_total_adj total_fte_adj ln_total_fte_adj total_mil_adj ln_total_mil_adj {
reghdfe `y' local_pct if HSI_pub == 1 & stateid != 6, absorb(unitid year) cl(unitid)
outreg2 using "D:\Gates CC Project\Output\localpct_HSI_noCA.xml", excel dec(3) alpha(0.001, 0.01, 0.05) symbol(***, **, *) ctitle(`y')  addstat(Adjusted within R-squared, `e(r2_a_within)') addtext(Covariates, NO, College FE, YES, Year FE, YES)

reghdfe `y' local_pct `covariates' if HSI_pub == 1 & stateid != 6, absorb(unitid year) cl(unitid)
outreg2 using "D:\Gates CC Project\Output\localpct_HSI_noCA.xml", excel dec(3) alpha(0.001, 0.01, 0.05) symbol(***, **, *) ctitle(`y')  addstat(Adjusted within R-squared, `e(r2_a_within)') addtext(Covariates, YES, College FE, YES, Year FE, YES)
}

//AANAPSI-eligible CCs

foreach y in total_adj ln_total_adj total_fte_adj ln_total_fte_adj total_mil_adj ln_total_mil_adj {
reghdfe `y' local_pct if aanapsi_eligible == 1 , absorb(unitid year) cl(unitid)
outreg2 using "D:\Gates CC Project\Output\localpct_AANAPSI.xml", excel dec(3) alpha(0.001, 0.01, 0.05) symbol(***, **, *) ctitle(`y')  addstat(Adjusted within R-squared, `e(r2_a_within)') addtext(Covariates, NO, College FE, YES, Year FE, YES)

reghdfe `y' local_pct `covariates' if aanapsi_eligible == 1, absorb(unitid year) cl(unitid)
outreg2 using "D:\Gates CC Project\Output\localpct_AANAPSI.xml", excel dec(3) alpha(0.001, 0.01, 0.05) symbol(***, **, *) ctitle(`y')  addstat(Adjusted within R-squared, `e(r2_a_within)') addtext(Covariates, YES, College FE, YES, Year FE, YES)
}

***Checking to see if CA is driving AANAPSI finding***

foreach y in total_adj ln_total_adj total_fte_adj ln_total_fte_adj total_mil_adj ln_total_mil_adj {
reghdfe `y' local_pct if aanapsi_eligible == 1 & stateid != 6, absorb(unitid year) cl(unitid)
outreg2 using "D:\Gates CC Project\Output\localpct_AANAPSI_noCA.xml", excel dec(3) alpha(0.001, 0.01, 0.05) symbol(***, **, *) ctitle(`y')  addstat(Adjusted within R-squared, `e(r2_a_within)') addtext(Covariates, NO, College FE, YES, Year FE, YES)

reghdfe `y' local_pct `covariates' if aanapsi_eligible == 1 & stateid != 6, absorb(unitid year) cl(unitid)
outreg2 using "D:\Gates CC Project\Output\localpct_AANAPSI_noCA.xml", excel dec(3) alpha(0.001, 0.01, 0.05) symbol(***, **, *) ctitle(`y')  addstat(Adjusted within R-squared, `e(r2_a_within)') addtext(Covariates, YES, College FE, YES, Year FE, YES)
}

//NASNI-eligible CCs (Native American Serving Nontribal Institutions)

foreach y in total_adj ln_total_adj total_fte_adj ln_total_fte_adj total_mil_adj ln_total_mil_adj {
reghdfe `y' local_pct if nasni_eligible == 1, absorb(unitid year) cl(unitid)
outreg2 using "D:\Gates CC Project\Output\localpct_NASNI.xml", excel dec(3) alpha(0.001, 0.01, 0.05) symbol(***, **, *) ctitle(`y')  addstat(Adjusted within R-squared, `e(r2_a_within)') addtext(Covariates, NO, College FE, YES, Year FE, YES)

reghdfe `y' local_pct `covariates' if nasni_eligible == 1, absorb(unitid year) cl(unitid)
outreg2 using "D:\Gates CC Project\Output\localpct_NASNI.xml", excel dec(3) alpha(0.001, 0.01, 0.05) symbol(***, **, *) ctitle(`y')  addstat(Adjusted within R-squared, `e(r2_a_within)') addtext(Covariates, YES, College FE, YES, Year FE, YES)
}

//Above-average share of URM students

foreach y in total_adj ln_total_adj total_fte_adj ln_total_fte_adj total_mil_adj ln_total_mil_adj {
reghdfe `y' local_pct if high_pct_urm_2yr == 1, absorb(unitid year) cl(unitid)
outreg2 using "D:\Gates CC Project\Output\localpct_aboveURM.xml", excel dec(3) alpha(0.001, 0.01, 0.05) symbol(***, **, *) ctitle(`y')  addstat(Adjusted within R-squared, `e(r2_a_within)') addtext(Covariates, NO, College FE, YES, Year FE, YES)

reghdfe `y' local_pct `covariates' if high_pct_urm_2yr == 1, absorb(unitid year) cl(unitid)
outreg2 using "D:\Gates CC Project\Output\localpct_aboveURM.xml", excel dec(3) alpha(0.001, 0.01, 0.05) symbol(***, **, *) ctitle(`y')  addstat(Adjusted within R-squared, `e(r2_a_within)') addtext(Covariates, YES, College FE, YES, Year FE, YES)
}

//Below-average share of URM students

foreach y in total_adj ln_total_adj total_fte_adj ln_total_fte_adj total_mil_adj ln_total_mil_adj {
reghdfe `y' local_pct if high_pct_urm_2yr == 0, absorb(unitid year) cl(unitid)
outreg2 using "D:\Gates CC Project\Output\localpct_belowURM.xml", excel dec(3) alpha(0.001, 0.01, 0.05) symbol(***, **, *) ctitle(`y')  addstat(Adjusted within R-squared, `e(r2_a_within)') addtext(Covariates, NO, College FE, YES, Year FE, YES)

reghdfe `y' local_pct `covariates' if high_pct_urm_2yr == 0, absorb(unitid year) cl(unitid)
outreg2 using "D:\Gates CC Project\Output\localpct_belowURM.xml", excel dec(3) alpha(0.001, 0.01, 0.05) symbol(***, **, *) ctitle(`y')  addstat(Adjusted within R-squared, `e(r2_a_within)') addtext(Covariates, YES, College FE, YES, Year FE, YES)
}

//Above-average share of low-income students

foreach y in total_adj ln_total_adj total_fte_adj ln_total_fte_adj total_mil_adj ln_total_mil_adj {
reghdfe `y' local_pct if high_pct_fgrnt_2yr == 1, absorb(unitid year) cl(unitid)
outreg2 using "D:\Gates CC Project\Output\localpct_abovelowincome.xml", excel dec(3) alpha(0.001, 0.01, 0.05) symbol(***, **, *) ctitle(`y')  addstat(Adjusted within R-squared, `e(r2_a_within)') addtext(Covariates, NO, College FE, YES, Year FE, YES)

reghdfe `y' local_pct `covariates' if high_pct_fgrnt_2yr == 1, absorb(unitid year) cl(unitid)
outreg2 using "D:\Gates CC Project\Output\localpct_abovelowincome.xml", excel dec(3) alpha(0.001, 0.01, 0.05) symbol(***, **, *) ctitle(`y')  addstat(Adjusted within R-squared, `e(r2_a_within)') addtext(Covariates, YES, College FE, YES, Year FE, YES)
}

//Below-average share of low-income students

foreach y in total_adj ln_total_adj total_fte_adj ln_total_fte_adj total_mil_adj ln_total_mil_adj {
reghdfe `y' local_pct if high_pct_fgrnt_2yr == 0, absorb(unitid year) cl(unitid)
outreg2 using "D:\Gates CC Project\Output\localpct_belowlowincome.xml", excel dec(3) alpha(0.001, 0.01, 0.05) symbol(***, **, *) ctitle(`y')  addstat(Adjusted within R-squared, `e(r2_a_within)') addtext(Covariates, NO, College FE, YES, Year FE, YES)

reghdfe `y' local_pct `covariates' if high_pct_fgrnt_2yr == 0, absorb(unitid year) cl(unitid)
outreg2 using "D:\Gates CC Project\Output\localpct_belowlowincome.xml", excel dec(3) alpha(0.001, 0.01, 0.05) symbol(***, **, *) ctitle(`y')  addstat(Adjusted within R-squared, `e(r2_a_within)') addtext(Covariates, YES, College FE, YES, Year FE, YES)
}

//END
