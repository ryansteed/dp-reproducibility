/*************************************************************************************************************
Imputed_Employment
This file uses data from the QCEW to estimate simulated state employment changes based on industry composition. 
To run this file, one must first download the data and run the code as described in qcew_data.do (contained in
the same folder as this do-file).
*************************************************************************************************************/

version 10.1
clear
set mem 100m
set more off
#delimit;

cd "$dir";
use data\qcew;
collapse (sum) employment if ownership!=0 & ownership!=8, by(state state_name industry NAICS year);
local year1 2009;
local year0 2008;
qui keep if year==`year1' | year==`year0';

/*************************************************************************************************************
1. Employment change by industry in other states
*************************************************************************************************************/
**Generate total employment by industry-year-month;
qui egen employment_total = total(employment), by(NAICS year);

**Generate total employment less industry employment in state s;
qui gen employment_rest = employment_total - employment;
qui replace employment_rest = employment_total if employment==.;

**Generate percent change in industry employment for other states. If data is missing for a state, use the
national total (which of course excludes the missing state);
qui sort state NAICS year;
qui gen g_employment_rest = (employment_rest/employment_rest[_n-1] - 1) if year==`year1';

**Generate change in state s in total employment;
qui gen g_employment = employment/employment[_n-1] - 1 if year==`year1' & NAICS==10;
qui gen d_employment = employment - employment[_n-1] if year==`year1' & NAICS==10;

/*************************************************************************************************************
2. Weighted employment change
*************************************************************************************************************/
**Predicted employment change by industry;
qui gen d_employment_hat_j = g_employment_rest * employment[_n-1] if year==`year1';

**Collapse dataset to add across industries by state;
qui gen naics4 = cond(NAICS>999&NAICS<9999&substr(industry,1,5)=="NAICS",1,0); **Dummy variable for 4 digit industries;
qui egen d_employment_hat1 = total(d_employment_hat_j) if year==`year1' & naics4==1, by(state);
qui egen d_employment_hat = mean(d_employment_hat1), by(state year);
qui drop d_employment_hat1;
qui gen g_employment_hat = d_employment_hat / employment[_n-1] if year==`year1' & NAICS==10;

/*************************************************************************************************************
3. Reshape
*************************************************************************************************************/
qui keep if year==`year1';
qui keep if NAICS==10;

graph drop _all;

reg g_employment g_employment_hat, robust;
local cons = round(_b[_cons],0.1);
local coef = round(_b[g_employment_hat],0.01);
local t_stat = round(_b[g_employment_hat]/_se[g_employment_hat],0.01);
local r2 = round(e(r2),0.01);

qui keep state state_name d_employment d_employment_hat;
qui save "data\Imputedemployment`year0'-`year1'", replace;
