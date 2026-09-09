/*NOTE: 
(1) RUN "C:\Users\k1ank00\OneDrive - FR Banks\anil\research\texas_home_equity\credit_constraints\AEJ_accept_replication_file\programs\Figures 2A, 2B, 4A, 4B, A2, A3, A4, A5, A6 Table 5.do" TO CREATE "C:\Users\k1ank00\OneDrive - FR Banks\anil\research\texas_home_equity\credit_constraints\AEJ_accept_replication_file\results\synthoutput.dta"
(2) RUN THE R CODE IN FILE "C:\Users\k1ank00\OneDrive - FR Banks\anil\research\texas_home_equity\credit_constraints\AEJ_accept_replication_file\programs\mcpanel_v2.R" TO CREATE "C:\Users\k1ank00\OneDrive - FR Banks\anil\research\texas_home_equity\credit_constraints\AEJ_accept_replication_file\results\mcpanel.dta"
*/

use "$resultsdir\mcpanel.dta", clear 
tsset year
label var mcpanel "Matrix Completion"
label var elasticnet "Elastic Net"
label var DID "Diff-in-Diff"
label var ADH "SCM-ADH"

merge 1:1 year using "$resultsdir\synthoutput.dta"
keep if _merge==1|_merge==3
drop _merge

**replace MCpanel ADH with regular synthetic control
drop ADH*
rename synth* ADH*
label var ADH "SCM-ADH"

tsline mcpanel elasticnet DID ADH, recast(connected) yline(0) xline(1997 2003, lp(dash)) xlab(1992(3)2007) title("Estimated Impact of HEL access on the LFPR using Alternative Synthetic Control Methods", size(small)) msymbol(s t oh o) saving("$resultsdir\Figure 5.gph", replace)

tsline elasticnet enplacebo*, xline(1997 2003, lp(dash)) xlab(1992(3)2007) legend(off) lp(solid) lc(black) lw(thick) title("SCM Estimates of the Effect of HEL Access on LFPR in Texas vs. Placebo States using Elasticnet", size(small)) saving("$resultsdir\Figure A7.gph", replace)

tsline mcpanel mcplacebo*, xline(1997 2003, lp(dash)) xlab(1992(3)2007) legend(off) lp(solid) lc(black) lw(thick) title("SCM Estimates of the Effect of HEL Access on LFPR in Texas vs. Placebo States using Matrix Completion", size(small)) saving("$resultsdir\Figure A8.gph", replace)

reshape long  mcplacebo enplacebo enTplacebo DIDplacebo ADHplacebo, i(year) j(id)

rename mcplacebo mcpanelplacebo
rename enplacebo elasticnetplacebo
rename enTplacebo elastnetTplacebo

**calculate standard errors similar to those in Doudchenk and Imbens (2016)
foreach x of varlist mcpanel elasticnet ADH DID {
cap drop test
gen test=`x'placebo^2
cap drop `x'_mse
egen `x'_mse=mean(test), by(year)
cap drop `x'_se
gen `x'_se=sqrt(`x'_mse) 
cap drop `x'_tstat
gen `x'_tstat=`x'/`x'_se
}

**2-sided
foreach x of varlist mcpanel elasticnet ADH DID {
cap drop `x'pval2s
gen `x'pval2s=abs(`x'placebo)>=abs(`x') 
}
table year if year>=1998, stat(mean mcpanel mcpanelpval2s elasticnet elasticnetpval2s /*mean ADH mean ADHpval2s*/)

**1-sided
foreach x of varlist mcpanel elasticnet ADH DID {
cap drop `x'pval1s
gen `x'pval1s=`x'placebo<=`x' 
}
table year if year>=1998, stat(mean mcpanel mcpanelpval1s elasticnet elasticnetpval1s /*mean ADH mean ADHpval1s*/)


**standardized
**generate pre-treatment means
foreach x of varlist mcpanel* elasticnet* ADH* DID* {
cap drop test
egen test=mean(`x'^2) if year<=1997, by(id)
cap drop prermse`x'
egen prermse`x'=mean(test), by(id)
replace prermse`x'=sqrt(prermse`x')

cap drop test
egen test=mean(`x'^2) if year>=1998, by(id)
cap drop postrmse`x'
egen postrmse`x'=mean(test), by(id)
replace postrmse`x'=sqrt(postrmse`x')
}


foreach x of varlist mcpanel elasticnet ADH DID {
cap drop `x'pvalstd
gen `x'pvalstd=abs(`x'placebo)/prermse`x'placebo>=abs(`x')/prermse`x'
}
table year if year>=1998, stat(mean mcpanel mcpanelpvalstd elasticnet elasticnetpvalstd /*mean ADH mean ADHpvalstd*/)


**average p-values
**2-sided
foreach x of varlist mcpanel elasticnet ADH DID {
cap drop `x'jpval2s
gen `x'jpval2s=postrmse`x'placebo>=postrmse`x'
}
table year if year>=1998, stat(mean mcpanel mcpaneljpval2s elasticnet elasticnetjpval2s /*mean ADH mean ADHjpval2s*/)

**2-sided standardized
foreach x of varlist mcpanel elasticnet ADH DID {
cap drop `x'jpvalstd2s
gen `x'jpvalstd2s=postrmse`x'placebo/prermse`x'placebo>=postrmse`x'/prermse`x' 
}
table year if year>=1998, stat(mean mcpanel mcpaneljpvalstd2s elasticnet elasticnetjpvalstd2s /*mean ADH mean ADHjpvalstd2s*/)

**p-value of pre-rmse
foreach x of varlist mcpanel elasticnet ADH DID {
cap drop `x'jpval2spre
gen `x'jpval2spre=prermse`x'placebo>=prermse`x'
}
table year if year>=1998, stat(mean mcpanel mcpaneljpval2spre elasticnet elasticnetjpval2spre /*mean ADH mean ADHjpval2spre*/)


foreach x of varlist *pvalstd {
label var `x' "Std. P-Value"
}

estimates clear
estpost tabstat DID DIDpvalstd ADH ADHpvalstd elasticnet elasticnetpvalstd mcpanel mcpanelpvalstd if year>=1998, by(year) statistics(mean) columns(var) nototal
foreach x of varlist DID ADH elasticnet mcpanel  {
mat b=e(`x')
erepost b=b
estadd mat pvalstd=e(`x'pvalstd), replace
**alternatively if estadd above doesnt work use the following to report p-values by reposting trick variance
**mat pval=e(`x'pvalstd)
**mat V=pval'*pval
**erepost V=V
sum `x' if year>=1998
estadd scal posteffect=r(mean), replace
sum `x'jpvalstd2s if year>=1998
estadd scal jointstdpval=r(mean), replace
sum postrmse`x'placebo if year>=1998
estadd scal postrmse=r(mean), replace

sum `x' if year>=1998 & year<=2003
estadd scal posteffect_HEL=r(mean), replace

sum `x' if year>=2004 & year<=2007
estadd scal posteffect_HELOC=r(mean), replace

sum `x' if year<1998
estadd scal preeffect=r(mean), replace
sum `x'jpval2spre if year<1998
estadd scal jointpvalpre=r(mean), replace
sum prermse`x' if year<1998
estadd scal prermse_treated=r(mean), replace
sum prermse`x'placebo if year<1998
estadd scal prermse_controls=r(mean), replace
eststo:
}
esttab using "$resultsdir\Table 6.rtf", replace main(b) aux(pvalstd) nostar brackets /*nogap*/ noobs nonotes noabbrev scalar("posteffect Treatment Effect" "jointstdpval Std. P-value" "posteffect_HEL Treatment Effect (HEL)" "posteffect_HELOC Treatment Effect (HEL+HELOC)"  "preeffect Pre-Treatment Mean Effect" "jointpvalpre Pre-Treatment P-value" "prermse_treated Pre-Treatment RMSPE: Texas" "prermse_controls Pre-Treatment RMSPE: Controls") mtitles("Diff-in-Diff" "ADH" "Elasticnet" "Matrix Completion") title("Estimated Treatment Effects of Home Equity Access on LFPR from Alternative SCM Methods with Standardized P-Values") addnotes("Standardized P-values reported in square brackets. Pre-treatment period: 1992-1997; Post-treatment period: 1998-2007; Treated group: Texas; Control Group: 49 remaining states.") align(ctr) varwidth(30) modelwidth(20)

