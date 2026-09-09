* Import competition and the gender employment gap in China
* Feicheng Wang, Krisztina Kis-Katos, Minghai Zhou
* Journal of Human Resources
* Replication codes for tables
* Stata version 17.0 SE—Standard Edition
* 16-05-2022
* Author: Feicheng Wang

* Set work directory
global basedir "."
global datadir "$basedir/data"
global codedir "$basedir/dofiles"
global figdir "$basedir/figures"
global tabledir "$basedir/tables"

**# Table 1: Participation rate of working age population by gender: 1990 and 2005 (%)
use "$datadir/wapop",clear
gen msh=empl_male/pop_male*100
gen msh_age1=empl_age1_male/pop_age1_male*100
gen msh_age2=empl_age2_male/pop_age2_male*100
gen msh_age3=empl_age3_male/pop_age3_male*100
gen msh_unempl=empl_unempl_male/pop_male*100
gen msh_nlfp=empl_nonlfp_male/pop_male*100
gen fsh=empl_female/pop_female*100
gen fsh_age1=empl_age1_female/pop_age1_female*100
gen fsh_age2=empl_age2_female/pop_age2_female*100
gen fsh_age3=empl_age3_female/pop_age3_female*100
gen fsh_unempl=empl_unempl_female/pop_female*100
gen fsh_nlfp=empl_nonlfp_female/pop_female*100
rename msh msh1
rename msh_age1 msh2
rename msh_age2 msh3
rename msh_age3 msh4
rename msh_unempl msh5
rename msh_nlfp msh6
rename fsh fsh1
rename fsh_age1 fsh2
rename fsh_age2 fsh3
rename fsh_age3 fsh4
rename fsh_unempl fsh5
rename fsh_nlfp fsh6
keep msh* fsh* year
reshape long msh fsh, i(year) j(cat)
reshape wide msh fsh, i(cat) j(year)
gen mfdiff1990=msh1990-fsh1990
gen mfdiff2005=msh2005-fsh2005
tostring cat,replace force
replace cat="Employed" if cat=="1"
replace cat="Age group 15–25" if cat=="2"
replace cat="Age group 26–35" if cat=="3"
replace cat="Age group 36–50" if cat=="4"
replace cat="Unemployed" if cat=="5"
replace cat="Non-participation" if cat=="6"
order cat msh1990 fsh1990 mfdiff1990 msh2005 fsh2005 mfdiff2005
keep cat *90 *05
format msh1990-mfdiff2005 %9.2f
label var cat "Working status"
label var msh1990 "Male" 
label var fsh1990 "Female"
label var mfdiff1990 "Male-Femal Difference"
label var msh2005 "Male"
label var fsh2005 "Female"
label var mfdiff2005 "Male-Femal Difference"
export excel using "$tabledir/table1.xlsx", firstrow(varlabels) replace

* Regressions
use "$datadir/regdata.dta",clear
global control90 "agrsh90 tersh90 soesh90 avlight90"

cap program drop chcof
program chcof, eclass
tempname bmat
	matrix `bmat' = e(b)
	matrix `bmat'[1,1] = cof_dtariff
	ereturn repost b = `bmat'
	
tempname semat
	matrix `semat' = e(V)
	matrix `semat'[1,1] = var_dtariff
	ereturn repost V = `semat'
end

**# Table 2: Import tariffs and prefecture-level employment rates, 1982-2005
* Panel A: ∆Employment rates 1990-2005
qui{
reg demplsh dtariff $control90 emplsh90, robust
sum demplsh if e(sample)
estadd scalar mean = r(mean)
est store empl1
reg demplsh_m dtariff $control90 emplsh_m90, robust
sum demplsh_m if e(sample)
estadd scalar mean = r(mean)
est store empl_m1
reg demplsh_f dtariff $control90 emplsh_f90, robust
sum demplsh_f if e(sample)
estadd scalar mean = r(mean)
est store empl_f1

* Test the difference between males and females
reg demplsh_m dtariff $control90 emplsh_m90
est store empl_m
reg demplsh_f dtariff $control90 emplsh_f90
est store empl_f
suest empl_m empl_f, robust

lincom [empl_m_mean]dtariff - [empl_f_mean]dtariff

* For the purpose of automatically exporting suest results
scalar cof_dtariff=r(estimate)
scalar var_dtariff=r(se)^2
reg demplsh_m dtariff $control90
chcof
sum demplsh_mf if e(sample)
estadd scalar mean = r(mean)
est store empl_mf1
}

esttab empl1 empl_m1 empl_f1 empl_mf1, ///
mtitles("All" "Male" "Female" "Male-Female Difference") star(* 0.10 ** 0.05 *** 0.01) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") keep(dtariff) ///
stats(N mean, fmt(%15.0fc %15.2fc) labels("Obs." `"Mean dependent (percentage points)"'))

* Panel B: ∆Employment rates 1982-1990
global control82 "agrsh82 tersh82"
qui{
reg demplsh8290 dtariff $control82 emplsh82, robust
sum demplsh8290 if e(sample)
estadd scalar mean = r(mean)
est store empl0
reg demplsh_m8290 dtariff $control82 emplsh_m82, robust
sum demplsh_m8290 if e(sample)
estadd scalar mean = r(mean)
est store empl_m0
reg demplsh_f8290 dtariff $control82 emplsh_f82, robust
sum demplsh_f8290  if e(sample)
estadd scalar mean = r(mean)
est store empl_f0

reg demplsh_m8290 dtariff $control82 emplsh_m82
est store empl_m
reg demplsh_f8290 dtariff $control82 emplsh_f82
est store empl_f
suest empl_m empl_f, robust

lincom [empl_m_mean]dtariff - [empl_f_mean]dtariff
scalar cof_dtariff=r(estimate)
scalar var_dtariff=r(se)^2

reg demplsh_m8290 dtariff $control82 emplsh_m82
chcof
sum demplsh_mf8290  if e(sample)
estadd scalar mean = r(mean)
est store empl_mf0
}

esttab empl0 empl_m0 empl_f0 empl_mf0, ///
mtitles("All" "Male" "Female" "Male-Female Difference") star(* 0.10 ** 0.05 *** 0.01) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") keep(dtariff) ///
stats(N mean, fmt(%15.0fc %15.2fc) labels("Obs." `"Mean dependent (percentage points)"'))

* Panel C: ∆Employment rates 1990-2005	 
reg demplsh dtariff $control90 demplsh8290 emplsh90, robust
sum demplsh if e(sample)
estadd scalar mean = r(mean)
est store empl10
reg demplsh_m dtariff $control90 demplsh_m8290 emplsh_m90, robust
sum demplsh_m if e(sample)
estadd scalar mean = r(mean)
est store empl_m10
reg demplsh_f dtariff $control90 demplsh_f8290 emplsh_f90, robust
sum demplsh_f  if e(sample)
estadd scalar mean = r(mean)
est store empl_f10

reg demplsh_m dtariff $control90 demplsh_m8290 emplsh_m90
est store empl_m
reg demplsh_f dtariff $control90 demplsh_f8290 emplsh_f90
est store empl_f
suest empl_m empl_f, robust

lincom [empl_m_mean]dtariff - [empl_f_mean]dtariff
scalar cof_dtariff=r(estimate)
scalar var_dtariff=r(se)^2

reg demplsh_m dtariff $control90 demplsh_m8290 emplsh_m90
chcof
sum demplsh_mf if e(sample)
estadd scalar mean = r(mean)
est store empl_mf10

estout empl_mf10 using "../../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

		
esttab empl10 empl_m10 empl_f10 empl_mf10, ///
mtitles("All" "Male" "Female" "Male-Female Difference") star(* 0.10 ** 0.05 *** 0.01) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") keep(dtariff) ///
stats(N mean, fmt(%15.0fc %15.2fc) labels("Obs." `"Mean dependent (percentage points)"'))

* Exporting estimation results to word
esttab empl1 empl_m1 empl_f1 empl_mf1 ///
using "$tabledir/table2.rtf", replace ///
nomtitles noobs collabels("") ///
title("Panel A: Delta Employment rates 1990-2005") ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(dtariff) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"')) ///
coeflabels(dtariff "Delta Import tariffs")
		 		 
esttab empl0 empl_m0 empl_f0 empl_mf0 ///
using "$tabledir/table2.rtf", append ///
nomtitles eqlabels(none) noobs collabels("") nonumbers ///
title("Panel B: Delta Employment rates 1982-1990") ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(dtariff) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"')) ///
coeflabels(dtariff "Delta Import tariffs")
	
esttab empl10 empl_m10 empl_f10 empl_mf10 ///
using "$tabledir/table2.rtf", append ///
nomtitles eqlabels(none) noobs collabels("") nonumbers ///
title("Panel C: Delta Employment rates 1990-2005") ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(dtariff) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"')) ///
coeflabels(dtariff "Delta Import tariffs")

**# Table 3: Import tariffs and prefecture-level employment by age and skill group, 1990–2005
* Panel A-C: by age
forvalues i=1/3 {
qui {
reg demplsh_age`i'_m dtariff $control90 emplsh_age`i'_m90, robust
sum demplsh_age`i'_m
estadd scalar mean = r(mean)
est store empl_age`i'_m
reg demplsh_age`i'_f dtariff $control90 emplsh_age`i'_f90, robust
sum demplsh_age`i'_f
estadd scalar mean = r(mean)
est store empl_age`i'_f

reg demplsh_age`i'_m dtariff $control90 emplsh_age`i'_m90
est store empl_m
reg demplsh_age`i'_f dtariff $control90 emplsh_age`i'_f90
est store empl_f
suest empl_m empl_f, robust
lincom [empl_m_mean]dtariff - [empl_f_mean]dtariff
scalar cof_dtariff=r(estimate)
scalar var_dtariff=r(se)^2

reg demplsh_age`i'_m dtariff $control90 emplsh_age`i'_m90
chcof
sum demplsh_age`i'_mf
estadd scalar mean = r(mean)
est store empl_age`i'
}
}

esttab empl_age1_m empl_age1_f empl_age1, ///
mtitles("Male" "Female" "Male-Female Difference") star(* 0.10 ** 0.05 *** 0.01) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") keep(dtariff) ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"'))

esttab empl_age1_m empl_age1_f empl_age1 ///
using "$tabledir/table3.rtf", replace ///
mtitles("Male" "Female" "Male-Female Difference") noobs collabels("") ///
title("Panel A: Aged 15-25") ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(dtariff) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"')) ///
coeflabels(dtariff "Delta Import tariffs")
	
esttab empl_age2_m empl_age2_f empl_age2, ///
mtitles("Male" "Female" "Male-Female Difference") star(* 0.10 ** 0.05 *** 0.01) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") keep(dtariff) ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"'))

esttab empl_age2_m empl_age2_f empl_age2 ///
using "$tabledir/table3.rtf", append ///
nomtitles eqlabels(none) noobs collabels("") nonumbers ///
title("Panel B: Aged 26-35") ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(dtariff) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"')) ///
coeflabels(dtariff "Delta Import tariffs")
		 		 
esttab empl_age3_m empl_age3_f empl_age3, ///
mtitles("Male" "Female" "Male-Female Difference") star(* 0.10 ** 0.05 *** 0.01) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") keep(dtariff) ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"'))

esttab empl_age3_m empl_age3_f empl_age3 ///
using "$tabledir/table3.rtf", append ///
nomtitles eqlabels(none) noobs collabels("") nonumbers ///
title("Panel C: Aged 36-50") ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(dtariff) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"')) ///
coeflabels(dtariff "Delta Import tariffs")
			 
* Panel D-F: by skill level
qui {
foreach sk in sk unsk {
reg demplsh_`sk'_m dtariff $control90 emplsh_`sk'_m90, robust
sum demplsh_`sk'_m
estadd scalar mean = r(mean)
est store empl_m_`sk'
reg demplsh_`sk'_f dtariff $control90 emplsh_`sk'_f90, robust
sum demplsh_`sk'_f
estadd scalar mean = r(mean)
est store empl_f_`sk'

reg demplsh_`sk'_m dtariff $control90 emplsh_`sk'_m90
est store empl_m
reg demplsh_`sk'_f dtariff $control90 emplsh_`sk'_f90
est store empl_f
suest empl_m empl_f, robust

lincom [empl_m_mean]dtariff - [empl_f_mean]dtariff
scalar cof_dtariff=r(estimate)
scalar var_dtariff=r(se)^2

reg demplsh_`sk'_m dtariff $control90 emplsh_`sk'_m90
chcof
sum demplsh_`sk'_mf
estadd scalar mean = r(mean)
est store empl_`sk'
}
}

esttab empl_m_unsk empl_f_unsk empl_unsk, ///
mtitles("Male" "Female" "Male-Female Difference") star(* 0.10 ** 0.05 *** 0.01) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") keep(dtariff) ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"'))

esttab empl_m_unsk empl_f_unsk empl_unsk ///
using "$tabledir/table3.rtf", append ///
nomtitles eqlabels(none) noobs collabels("") nonumbers ///
title("Panel D: Low-skilled workers") ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(dtariff) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"')) ///
coeflabels(dtariff "Delta Import tariffs")

esttab empl_m_sk empl_f_sk empl_sk, ///
mtitles("Male" "Female" "Male-Female Difference") star(* 0.10 ** 0.05 *** 0.01) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") keep(dtariff) ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"'))

esttab empl_m_sk empl_f_sk empl_sk ///
using "$tabledir/table3.rtf", append ///
nomtitles eqlabels(none) noobs collabels("") nonumbers ///
title("Panel E: High-skilled workers") ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(dtariff) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"')) ///
coeflabels(dtariff "Delta Import tariffs")

**# Table 4: Employment shares in state-owned and private formal firms, 1995–2004
* Panel A: In all formal firms
qui {
reg demplsh_m9504 dtariff $control90 emplsh_m95, robust
sum demplsh_m9504 if e(sample)
estadd scalar mean = r(mean)
est store emplsh_m
reg demplsh_f9504 dtariff $control90 emplsh_f95, robust
sum demplsh_f9504 if e(sample)
estadd scalar mean = r(mean)
est store emplsh_f

reg demplsh_m9504 dtariff $control90 emplsh_m95
est store empl_m
reg demplsh_f9504 dtariff $control90 emplsh_f95
est store empl_f
suest empl_m empl_f, robust

lincom [empl_m_mean]dtariff - [empl_f_mean]dtariff
scalar cof_dtariff=r(estimate)
scalar var_dtariff=r(se)^2

reg demplsh_f9504 dtariff $control90 emplsh_f95
chcof
sum demplsh_mf9504 if e(sample)
estadd scalar mean = r(mean)
est store emplsh
}

esttab emplsh_m emplsh_f emplsh, ///
mtitles("Male" "Female" "Male-Female Difference") star(* 0.10 ** 0.05 *** 0.01) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") keep(dtariff) ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"'))

esttab emplsh_m emplsh_f emplsh ///
using "$tabledir/table4.rtf", replace ///
mtitles("Male" "Female" "Male-Female Difference") noobs collabels("") ///
title("Panel A: In all formal firms") ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(dtariff) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"')) ///
coeflabels(dtariff "Delta Import tariffs")

* Panel B: In SOEs
qui {
reg demplsh_m_soe9504 dtariff $control90 emplsh_m_soe95, robust
sum demplsh_m_soe9504 if e(sample)
estadd scalar mean = r(mean)
est store emplsh_m_soe
reg demplsh_f_soe9504 dtariff $control90 emplsh_f_soe95, robust
sum demplsh_f_soe9504 if e(sample)
estadd scalar mean = r(mean)
est store emplsh_f_soe

reg demplsh_m_soe9504 dtariff $control90 emplsh_m_soe95
est store empl_m
reg demplsh_f_soe9504 dtariff $control90 emplsh_f_soe95
est store empl_f
suest empl_m empl_f, robust

lincom [empl_m_mean]dtariff - [empl_f_mean]dtariff
scalar cof_dtariff=r(estimate)
scalar var_dtariff=r(se)^2

reg demplsh_f_soe9504 dtariff $control90 emplsh_f_soe95
chcof
sum demplsh_mf_soe9504 if e(sample)
estadd scalar mean = r(mean)
est store emplsh_soe
}

esttab emplsh_m_soe emplsh_f_soe emplsh_soe, ///
mtitles("Male" "Female" "Male-Female Difference") star(* 0.10 ** 0.05 *** 0.01) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") keep(dtariff) ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"'))

esttab emplsh_m_soe emplsh_f_soe emplsh_soe ///
using "$tabledir/table4.rtf", append ///
nomtitles eqlabels(none) noobs collabels("") nonumbers ///
title("Panel B: In SOEs") ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(dtariff) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"')) ///
coeflabels(dtariff "Delta Import tariffs")

* Panel C: In Non-SOEs
qui{
reg demplsh_m_nsoe9504 dtariff $control90 emplsh_m_nsoe95, robust
sum demplsh_m_nsoe9504 if e(sample)
estadd scalar mean = r(mean)
est store emplsh_m_nsoe
reg demplsh_f_nsoe9504 dtariff $control90 emplsh_f_nsoe95, robust
sum demplsh_f_nsoe9504  if e(sample)
estadd scalar mean = r(mean)
est store emplsh_f_nsoe

reg demplsh_m_nsoe9504 dtariff $control90 emplsh_m_nsoe95
est store empl_m
reg demplsh_f_nsoe9504 dtariff $control90 emplsh_f_nsoe95
est store empl_f
suest empl_m empl_f, robust

lincom [empl_m_mean]dtariff - [empl_f_mean]dtariff
scalar cof_dtariff=r(estimate)
scalar var_dtariff=r(se)^2


reg demplsh_f_nsoe9504 dtariff $control90 emplsh_f_nsoe95
chcof
sum demplsh_mf_nsoe9504 if e(sample)
estadd scalar mean = r(mean)
est store emplsh_nsoe
}

esttab emplsh_m_nsoe emplsh_f_nsoe emplsh_nsoe, ///
mtitles("Male" "Female" "Male-Female Difference") star(* 0.10 ** 0.05 *** 0.01) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") keep(dtariff) ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"'))

esttab emplsh_m_nsoe emplsh_f_nsoe emplsh_nsoe ///
using "$tabledir/table4.rtf", append ///
nomtitles eqlabels(none) noobs collabels("") nonumbers ///
title("Panel C: In Non-SOEs") ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(dtariff) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"')) ///
coeflabels(dtariff "Delta Import tariffs")

**# Table 5: Robustness checks: IV regressions
qui {
ivreg2 demplsh_m (dtariff = tariff92) $control90 emplsh_m90, robust first savefirst savefprefix(f_m_)
weakivtest 
estadd scalar F_eff = r(F_eff)
est store empliv_m
ivreg2 demplsh_f (dtariff = tariff92) $control90 emplsh_f90, robust first savefirst savefprefix(f_f_)
weakivtest 
estadd scalar F_eff = r(F_eff)
est store empliv_f

* suest does not work with ivreg2, using gmm
gmm ///
(eq1: demplsh_m - {xb: dtariff $control90 emplsh_m90 _cons}) ///
(eq2: demplsh_f - {xc: dtariff $control90 emplsh_f90 _cons}), ///
instruments(eq1: tariff92 $control90 emplsh_m90) ///
instruments(eq2: tariff92 $control90 emplsh_f90) ///
onestep winitial(unadjusted, indep)

lincom _b[xb:dtariff] - _b[xc:dtariff]  
scalar cof_dtariff=r(estimate)
scalar var_dtariff=r(se)^2

ivreg2 demplsh_m (dtariff = tariff92) $control90 emplsh_m90
chcof
est store empliv
}

esttab empliv_m empliv_f empliv, ///
mtitles("Male" "Female" "Male-Female Difference") star(* 0.10 ** 0.05 *** 0.01) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") keep(dtariff) ///
stats(F_eff, fmt(%15.2fc) labels(`"First-stage KP F-statistics"'))

esttab empliv_m empliv_f empliv ///
using "$tabledir/table5.rtf", replace ///
mtitles("Male" "Female" "Male-Female Difference") noobs collabels("") ///
title("Panel A: Second-stage results") ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(dtariff) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
stats(F_eff, fmt(%15.2fc) labels(`"First-stage KP F-statistics"')) ///
coeflabels(dtariff "Delta Import tariffs")

esttab f_m_dtariff f_f_dtariff, ///
mtitles("Male" "Female") star(* 0.10 ** 0.05 *** 0.01) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") keep(tariff92)

esttab f_m_dtariff f_f_dtariff ///
using "$tabledir/table5.rtf", append ///
nomtitles eqlabels(none) noobs collabels("") nonumbers ///
title("Panel B: First-stage results") ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(tariff92) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
stats() ///
coeflabels(tariff92 "Import tariffs in 1992")

**# Table 6: Heterogeneity by migration status and hukou type

* Panel A: Full sample (columns 4-9) -- Urban and rural hukou
foreach hk in u r {
reg demplsh_`hk'hk_m dtariff $control90 emplsh_`hk'hk_m90, robust
sum demplsh_`hk'hk_m
estadd scalar mean = r(mean)
est store empl_m_`hk'hk
reg demplsh_`hk'hk_f dtariff $control90 emplsh_`hk'hk_f90, robust
sum demplsh_`hk'hk_f
estadd scalar mean = r(mean)
est store empl_f_`hk'hk

reg demplsh_`hk'hk_m dtariff $control90 emplsh_`hk'hk_m90
est store empl_m
reg demplsh_`hk'hk_f dtariff $control90 emplsh_`hk'hk_f90
est store empl_f
suest empl_m empl_f, robust
lincom [empl_m_mean]dtariff - [empl_f_mean]dtariff
scalar cof_dtariff=r(estimate)
scalar var_dtariff=r(se)^2

reg demplsh_`hk'hk_m dtariff $control90 emplsh_`hk'hk_m90
chcof
sum demplsh_`hk'hk_mf
estadd scalar mean = r(mean)
est store empl_`hk'hk
}

esttab empl_m1 empl_f1 empl_mf1 empl_m_uhk empl_f_uhk empl_uhk empl_m_rhk empl_f_rhk empl_rhk, ///
mtitles("Male" "Female" "Male-Female Difference" "Male" "Female" "Male-Female Difference" "Male" "Female" "Male-Female Difference") cells("b(fmt(2)star)" "t(fmt(2)par abs)") keep(dtariff) ///
star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"'))

esttab empl_m1 empl_f1 empl_mf1 empl_m_uhk empl_f_uhk empl_uhk empl_m_rhk empl_f_rhk empl_rhk ///
using "$tabledir/table6.rtf",replace ///
mtitles("Male" "Female" "Male-Female Difference" "Male" "Female" "Male-Female Difference" "Male" "Female" "Male-Female Difference") noobs collabels("") ///
title("Panel A: Full sample") ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(dtariff) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"')) ///
coeflabels(dtariff "Delta Import tariffs")

* Panel B and C: Non-migrants and migrants (columns 1-3)
qui {
foreach migr in mig nmig {
reg demplsh_`migr'_m dtariff $control90 emplsh_`migr'_m90, robust
sum demplsh_`migr'_m
estadd scalar mean = r(mean)
est store empl_m_`migr'
reg demplsh_`migr'_f dtariff $control90 emplsh_`migr'_f90, robust
sum demplsh_`migr'_f
estadd scalar mean = r(mean)
est store empl_f_`migr'

reg demplsh_`migr'_m dtariff $control90 emplsh_`migr'_m90
est store empl_m
reg demplsh_`migr'_f dtariff $control90 emplsh_`migr'_f90
est store empl_f
suest empl_m empl_f, robust

lincom [empl_m_mean]dtariff - [empl_f_mean]dtariff
scalar cof_dtariff=r(estimate)
scalar var_dtariff=r(se)^2

reg demplsh_`migr'_m dtariff $control90 emplsh_`migr'_m90
chcof
sum demplsh_`migr'_mf
estadd scalar mean = r(mean)
est store empl_`migr'
}
}

* Panel B and C: Non-migrants and migrants by hukou (columns 4-9)
qui { 
  foreach migr in mig nmig {
    foreach hk in u r {
reg demplsh_`hk'hk_`migr'_m dtariff $control90 emplsh_`hk'hk_`migr'_m90, robust
sum demplsh_`hk'hk_`migr'_m
estadd scalar mean = r(mean)
est store empl_m_`hk'_`migr'
reg demplsh_`hk'hk_`migr'_f dtariff $control90 emplsh_`hk'hk_`migr'_f90, robust
sum demplsh_`hk'hk_`migr'_f
estadd scalar mean = r(mean)
est store empl_f_`hk'_`migr'

reg demplsh_`hk'hk_`migr'_m dtariff $control90 emplsh_`hk'hk_`migr'_m90
est store empl_m
reg demplsh_`hk'hk_`migr'_f dtariff $control90 emplsh_`hk'hk_`migr'_f90
est store empl_f
suest empl_m empl_f, robust

lincom [empl_m_mean]dtariff - [empl_f_mean]dtariff
scalar cof_dtariff=r(estimate)
scalar var_dtariff=r(se)^2

reg demplsh_`hk'hk_`migr'_m dtariff $control90 emplsh_`hk'hk_`migr'_m90
chcof
sum demplsh_`hk'hk_`migr'_mf
estadd scalar mean = r(mean)
est store empl_`hk'_`migr'
    }
  }
}

esttab empl_m_nmig empl_f_nmig empl_nmig empl_m_u_nmig empl_f_u_nmig empl_u_nmig empl_m_r_nmig empl_f_r_nmig empl_r_nmig, ///
mtitles("Male" "Female" "Male-Female Difference" "Male" "Female" "Male-Female Difference" "Male" "Female" "Male-Female Difference") cells("b(fmt(2)star)" "t(fmt(2)par abs)") keep(dtariff) ///
star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"'))

esttab empl_m_nmig empl_f_nmig empl_nmig empl_m_u_nmig empl_f_u_nmig empl_u_nmig empl_m_r_nmig empl_f_r_nmig empl_r_nmig ///
using "$tabledir/table6.rtf", append ///
nomtitles eqlabels(none) noobs collabels("") nonumbers ///
title("Panel B: Non-migrants") ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(dtariff) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"')) ///
coeflabels(dtariff "Delta Import tariffs")

esttab empl_m_mig empl_f_mig empl_mig empl_m_u_mig empl_f_u_mig empl_u_mig empl_m_r_mig empl_f_r_mig empl_r_mig, ///
mtitles("Male" "Female" "Male-Female Difference" "Male" "Female" "Male-Female Difference" "Male" "Female" "Male-Female Difference") cells("b(fmt(2)star)" "t(fmt(2)par abs)") keep(dtariff) ///
star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"'))

esttab empl_m_mig empl_f_mig empl_mig empl_m_u_mig empl_f_u_mig empl_u_mig empl_m_r_mig empl_f_r_mig empl_r_mig ///
using "$tabledir/table6.rtf", append ///
nomtitles eqlabels(none) noobs collabels("") nonumbers ///
title("Panel C: Migrants") ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(dtariff) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"')) ///
coeflabels(dtariff "Delta Import tariffs")

**# Table 7: Robustness checks: Tariff decomposition, further policy controls and weights

* Panel A: Controlling for input tariffs
cap program drop chcof_tab7_1
program chcof_tab7_1, eclass
tempname bmat
	matrix `bmat' = e(b)
	matrix `bmat'[1,1] = cof_dtariff
	matrix `bmat'[1,2] = cof_dtariff_input
	ereturn repost b = `bmat'
	
tempname semat
	matrix `semat' = e(V)
	matrix `semat'[1,1] = var_dtariff
	matrix `semat'[2,2] = var_dtariff_input
	ereturn repost V = `semat'
end
qui {
reg demplsh_m dtariff dtariff_input $control90 emplsh_m90, robust
est store empl_m_robust1
reg demplsh_f dtariff dtariff_input $control90 emplsh_f90, robust
est store empl_f_robust1

reg demplsh_m dtariff dtariff_input $control90 emplsh_m90
est store empl_m
reg demplsh_f dtariff dtariff_input $control90 emplsh_f90
est store empl_f

suest empl_m empl_f, robust
foreach var in dtariff  dtariff_input {
lincom [empl_m_mean]`var' - [empl_f_mean]`var'
scalar cof_`var'=r(estimate)
scalar var_`var'=r(se)^2
}

reg demplsh_m dtariff dtariff_input
chcof_tab7_1
est store empl_robust1
}

esttab empl_m_robust1 empl_f_robust1 empl_robust1, ///
mtitles("Male" "Female" "Male-Female Difference") ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") keep(dtariff dtariff_input) ///
star(* 0.10 ** 0.05 *** 0.01)

esttab empl_m_robust1 empl_f_robust1 empl_robust1 ///
using "$tabledir/table7.rtf",replace ///
mtitles("Male" "Female" "Male-Female Difference") noobs collabels("") ///
title("Panel A: Controlling for input tariffs") ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(dtariff dtariff_input) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
stats() ///
coeflabels(dtariff "Delta Import tariffs: Output" ///
		   dtariff_input "Delta Import tariffs: Input")
		 		 
* Panel B: Decomposing import tariffs
cap program drop chcof_tab7_2
program chcof_tab7_2, eclass
tempname bmat
	matrix `bmat' = e(b)
	matrix `bmat'[1,1] = cof_dtariff_minmaf
	matrix `bmat'[1,2] = cof_dtariff_agr
	ereturn repost b = `bmat'
	
tempname semat
	matrix `semat' = e(V)
	matrix `semat'[1,1] = var_dtariff_minmaf
	matrix `semat'[2,2] = var_dtariff_agr
	ereturn repost V = `semat'
end

qui {
reg demplsh_m dtariff_minmaf dtariff_agr $control90 emplsh_m90, robust
est store empl_m_robust2
reg demplsh_f dtariff_minmaf dtariff_agr $control90 emplsh_f90, robust
est store empl_f_robust2

reg demplsh_m dtariff_minmaf dtariff_agr $control90 emplsh_m90
est store empl_m
reg demplsh_f dtariff_minmaf dtariff_agr $control90 emplsh_f90
est store empl_f

suest empl_m empl_f, robust
foreach var of varlist dtariff_minmaf dtariff_agr {
lincom [empl_m_mean]`var' - [empl_f_mean]`var'
scalar cof_`var'=r(estimate)
scalar var_`var'=r(se)^2
}

reg demplsh_m dtariff_minmaf dtariff_agr
chcof_tab7_2
est store empl_robust2
}

esttab empl_m_robust2 empl_f_robust2 empl_robust2, ///
mtitles("Male" "Female" "Male-Female Difference") ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") keep(dtariff_minmaf dtariff_agr) ///
star(* 0.10 ** 0.05 *** 0.01)

esttab empl_m_robust2 empl_f_robust2 empl_robust2 ///
using "$tabledir/table7.rtf",append ///
nomtitles eqlabels(none) noobs collabels("") nonumbers ///
title("Panel B: Decomposing import tariffs") ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(dtariff_minmaf dtariff_agr) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
stats() ///
coeflabels(dtariff_minmaf "Delta Industrial tariffs" ///
		   dtariff_agr "Delta Agricultural tariffs")
		 
* Panel C: Import tariffs including all sectors
cap program drop chcof_tab7_3
program chcof_tab7_3, eclass
tempname bmat
	matrix `bmat' = e(b)
	matrix `bmat'[1,1] = cof_dtariff_allind
	ereturn repost b = `bmat'
	
tempname semat
	matrix `semat' = e(V)
	matrix `semat'[1,1] = var_dtariff_allind
	ereturn repost V = `semat'
end

qui{
reg demplsh_m dtariff_allind $control90 emplsh_m90, robust
sum demplsh_m if e(sample)
estadd scalar mean = r(mean)
est store empl_m_robust3
reg demplsh_f dtariff_allind $control90 emplsh_f90, robust
sum demplsh_f if e(sample)
estadd scalar mean = r(mean)
est store empl_f_robust3

reg demplsh_m dtariff_allind $control90 emplsh_m90
est store empl_m
reg demplsh_f dtariff_allind $control90 emplsh_f90
est store empl_f
suest empl_m empl_f, robust

lincom [empl_m_mean]dtariff_allind - [empl_f_mean]dtariff_allind
scalar cof_dtariff_allind=r(estimate)
scalar var_dtariff_allind=r(se)^2

reg demplsh_m dtariff_allind
chcof_tab7_3
sum demplsh_mf if e(sample)
estadd scalar mean = r(mean)
est store empl_robust3
}

esttab empl_m_robust3 empl_f_robust3 empl_robust3, ///
mtitles("Male" "Female" "Male-Female Difference") ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") keep(dtariff_allind) ///
star(* 0.10 ** 0.05 *** 0.01)

esttab empl_m_robust3 empl_f_robust3 empl_robust3 ///
using "$tabledir/table7.rtf",append ///
nomtitles eqlabels(none) noobs collabels("") nonumbers ///
title("Panel C: Import tariffs including all sectors") ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(dtariff_allind) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
stats() ///
coeflabels(dtariff_allind "Delta Import tariffs: All sectors")
		
* Panel D: Further policy controls
cap program drop chcof_tab7_4
program chcof_tab7_4, eclass
tempname bmat
	matrix `bmat' = e(b)
	matrix `bmat'[1,1] = cof_dtariff
	matrix `bmat'[1,2] = cof_dntb
	matrix `bmat'[1,3] = cof_dtariff_exp
	matrix `bmat'[1,4] = cof_dntrgap
	matrix `bmat'[1,5] = cof_dsubsidy
	matrix `bmat'[1,6] = cof_dexp_lice	
	matrix `bmat'[1,7] = cof_dfdi  
	ereturn repost b = `bmat'
	
tempname semat
	matrix `semat' = e(V)
	matrix `semat'[1,1] = var_dtariff
	matrix `semat'[2,2] = var_dntb
	matrix `semat'[3,3] = var_dtariff_exp
	matrix `semat'[4,4] = var_dntrgap
	matrix `semat'[5,5] = var_dsubsidy
	matrix `semat'[6,6] = var_dexp_lice
	matrix `semat'[7,7] = var_dfdi  
	ereturn repost V = `semat'
end

global policy "dntb dtariff_exp dntrgap dsubsidy dexp_lice dfdi"
qui {
reg demplsh_m dtariff $policy $control90 emplsh_m90, robust
est store empl_m_robust4
reg demplsh_f dtariff $policy $control90 emplsh_f90, robust
est store empl_f_robust4

reg demplsh_m dtariff $policy $control90 emplsh_m90
est store empl_m
reg demplsh_f dtariff $policy $control90 emplsh_f90
est store empl_f
suest empl_m empl_f, robust

lincom [empl_m_mean]dtariff - [empl_f_mean]dtariff
scalar cof_dtariff=r(estimate)
scalar var_dtariff=r(se)^2

foreach var of global policy {
lincom [empl_m_mean]`var' - [empl_f_mean]`var'
scalar cof_`var'=r(estimate)
scalar var_`var'=r(se)^2
}

reg demplsh_m dtariff $policy
chcof_tab7_4
est store empl_robust4
}

esttab empl_m_robust4 empl_f_robust4 empl_robust4, ///
mtitles("Male" "Female" "Male-Female Difference") ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") keep(dtariff $policy) ///
star(* 0.10 ** 0.05 *** 0.01)

esttab empl_m_robust4 empl_f_robust4 empl_robust4 ///
using "$tabledir/table7.rtf",append ///
nomtitles eqlabels(none) noobs collabels("") nonumbers ///
title("Panel D: Further policy controls") ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(dtariff $policy) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
stats() ///
coeflabels(dtariff "Delta Import tariffs" ///
           dntb "Delta NTBs" ///
           dtariff_exp "Delta Export tariffs" ///
		   dntrgap "Delta NTR gaps" ///
		   dsubsidy "Delta Export subsidies" ///
		   dexp_lice "Delta Export licenses" ///
		   dfdi "Delta FDI restrictions")

* Panel E: Weighting using initial population size
qui {
reg demplsh_m dtariff $control90 emplsh_m90 [aw=pop_w], robust
est store empl_m_robust5
reg demplsh_f dtariff $control90 emplsh_f90 [aw=pop_w], robust
est store empl_f_robust5

reg demplsh_m dtariff $control90 emplsh_m90 [aw=pop_w]
est store empl_m
reg demplsh_f dtariff $control90 emplsh_f90 [aw=pop_w]
est store empl_f
suest empl_m empl_f, robust

lincom [empl_m_mean]dtariff - [empl_f_mean]dtariff
scalar cof_dtariff=r(estimate)
scalar var_dtariff=r(se)^2

reg demplsh_m dtariff
chcof
est store empl_robust5
}

esttab empl_m_robust5 empl_f_robust5 empl_robust5, ///
mtitles("Male" "Female" "Male-Female Difference") ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") keep(dtariff) ///
star(* 0.10 ** 0.05 *** 0.01)

esttab empl_m_robust5 empl_f_robust5 empl_robust5 ///
using "$tabledir/table7.rtf",append ///
nomtitles eqlabels(none) noobs collabels("") nonumbers ///
title("Panel E: Weighting using initial population size") ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(dtariff) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
stats() ///
coeflabels(dtariff "Delta Import tariffs")

**# Table 8: Channels: Changes in the local economy and in formal firms
* Panel A: Dependent: Expansion of female intensive sectors
qui {
reg dfiss dtariff $control90 fiss90, robust
sum dfiss if e(sample)
estadd scalar mean = r(mean)
est store fiss

reg dfiss_firm dtariff $control90 fiss_firm95, robust
sum dfiss_firm if e(sample)
estadd scalar mean = r(mean)
est store fiss_firm

reg dfiss_soe dtariff $control90 fiss_soe95, robust
sum dfiss_soe if e(sample)
estadd scalar mean = r(mean)
est store fiss_soe

reg dfiss_nsoe dtariff $control90 fiss_nsoe95, robust
sum dfiss_nsoe if e(sample)
estadd scalar mean = r(mean)
est store fiss_nsoe
}
estout fiss_nsoe using "../../results/table2.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
esttab fiss fiss_firm fiss_soe fiss_nsoe, ///
mtitles("Local economy" "Formal industry" "SOEs" "Non-SOEs") ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") keep(dtariff) ///
star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"'))

esttab fiss fiss_firm fiss_soe fiss_nsoe ///
using "$tabledir/table8.rtf",replace ///
mtitles("Local economy" "Formal industry" "SOEs" "Non-SOEs") noobs collabels("") ///
title("Panel A: Dependent: Expansion of female intensive sectors") ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(dtariff) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"')) ///
coeflabels(dtariff "Delta Import tariffs")
		 
* Panel B: Dependent: Change in discrimination
qui {
reg ddisc dtariff $control90 disc95, robust
sum ddisc if e(sample)
estadd scalar mean = r(mean)
est store disc_firm

reg ddisc_soe dtariff $control90 disc_soe95, robust
sum ddisc_soe if e(sample)
estadd scalar mean = r(mean)
est store disc_soe

reg ddisc_nsoe dtariff $control90 disc_nsoe95, robust
sum ddisc_nsoe if e(sample)
estadd scalar mean = r(mean)
est store disc_nsoe
}
estout disc_nsoe using "../../results/table3.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
esttab disc_firm disc_soe disc_nsoe, ///
mtitles("Formal industry" "SOEs" "Non-SOEs") ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") keep(dtariff) ///
star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent"'))

esttab disc_firm disc_soe disc_nsoe ///
using "$tabledir/table8.rtf",append ///
nomtitles eqlabels(none) noobs collabels("") nonumbers ///
title("Panel B: Dependent: Change in discrimination") ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(dtariff) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent"')) ///
coeflabels(dtariff "Delta Import tariffs")

* Panel C: Dependent: Change in computer intensity
qui {
reg dcompg dtariff $control90 compg90, robust
sum dcompg if e(sample)
estadd scalar mean = r(mean)
est store compsh

reg dcompg_ind dtariff $control90 compg_ind95, robust
sum dcompg_ind if e(sample)
estadd scalar mean = r(mean)
est store compsh_firm

reg dcompg_soe dtariff $control90 compg_soe95, robust
sum dcompg_soe if e(sample)
estadd scalar mean = r(mean)
est store compsh_soe

reg dcompg_nsoe dtariff $control90 compg_nsoe95, robust
sum dcompg_nsoe if e(sample)
estadd scalar mean = r(mean)
est store compsh_nsoe
}
*** EDITED by Annie
estout compsh_nsoe using "../../results/table4.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
***
esttab compsh compsh_firm compsh_soe compsh_nsoe, ///
mtitles("Local economy" "Formal industry" "SOEs" "Non-SOEs") ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") keep(dtariff) ///
star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"'))

esttab compsh compsh_firm compsh_soe compsh_nsoe ///
using "$tabledir/table8.rtf",append ///
nomtitles eqlabels(none) noobs collabels("") nonumbers ///
title("Panel C: Dependent: Change in computer intensity") ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(dtariff) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"')) ///
coeflabels(dtariff "Delta Import tariffs")

* Panel D: Dependent: Change in GDP per capita
qui {
reg dlngdppc dtariff $control90 lngdppc90, robust
sum dlngdppc if e(sample)
estadd scalar mean = r(mean)
est store gdppc
}

esttab gdppc, ///
mtitles("Local economy") ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") keep(dtariff) ///
star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"'))

esttab gdppc ///
using "$tabledir/table8.rtf",append ///
nomtitles eqlabels(none) noobs collabels("") nonumbers ///
title("Panel D: Dependent: Change in GDP per capita") ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(dtariff) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent"')) ///
coeflabels(dtariff "Delta Import tariffs")



* Online Appendix Tables

**# Table A.1: Summary statistics of key variables
global channel "dfiss dfiss_firm dfiss_soe dfiss_nsoe ddisc ddisc_soe ddisc_nsoe dcompg dcompg_ind dcompg_soe dcompg_nsoe dlngdppc"

estpost sum dtariff demplsh demplsh_m demplsh_f demplsh_mf $channel $control90
est store sum

esttab sum using "$tabledir/table_a1.rtf", replace ///
cells("mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))") ///
noobs collabels("Mean" "Standard Deviation" "Minimum" "Maximum") ///
title("Table A.1: Summary statistics of key variables") ///
coeflabels(dtariff "Delta Import tariffs (percentage points)" ///
           demplsh "Delta Employment rate (percentage points)" ///
           demplsh_m "Delta Male employment rate (percentage points)" ///
           demplsh_f "Delta Female employment rate (percentage points)" ///
		   demplsh_mf "Delta Male-female employment rate difference (percentage points)" ///  
		   dfiss "Delta Female intensity (percentage points)" ///
		   dfiss_firm "Delta Female intensity: Formal industrial sector (percentage points)" ///
		   dfiss_soe "Delta Female intensity: SOEs (percentage points)" ///
		   dfiss_nsoe "Delta Female intensity: Non-SOEs (percentage points)" ///
		   ddisc "Delta Discrimination: Formal industrial sector" ///
		   ddisc_soe "Delta Discrimination: SOEs" ///
		   ddisc_nsoe "Delta Discrimination: Non-SOEs" ///
		   dcompg "Delta Computer intensity (percentage points)" ///
		   dcompg_ind "Delta Computer intensity: Formal industrial sector (percentage points)" ///
		   dcompg_soe "Delta Computer intensity: SOEs (percentage points)" ///
		   dcompg_nsoe "Delta Computer intensity: Non-SOEs (percentage points)" ///
		   dlngdppc "Delta GDP per capita (ln)" ///
		   agrsh90 "1990 agricultural sector employment share (percentage points)" ///
		   tersh90 "1990 tertiary sector employment share (percentage points)" ///
		   soesh90 "1990 SOE employment share (percentage points)" ///
		   avlight90 "1990 nightlights")
		   
**# Table A.2: Changes of prefecture-level import tariff exposure: 1992-2005
gen dtariff_abs=-dtariff
estpost sum tariff92, detail
est store tariff92
estpost sum tariff05, detail
est store tariff05
estpost sum dtariff_abs, detail
est store dtariff

esttab tariff92 tariff05 dtariff ///
using "$tabledir/table_a2.rtf", replace ///
mtitles("1992 (percentage points)" "2005 (percentage points)" "Reduction (percentage points)") ///
nonum noobs collabels(none) gaps plain ///
cells("mean(fmt(2))") ///
rename(tariff92 "mean" tariff05 "mean" dtariff_abs "mean") ///
coeflabels(mean "Mean")

foreach i in 95 75 50 25 5 {
esttab tariff92 tariff05 dtariff using "$tabledir/table_a2.rtf", append ///
nonum noobs nomtitle collabels(none) gaps plain ///
cells("p`i'(fmt(2))") ///
rename(tariff92 "p`i'" tariff05 "p`i'" dtariff_abs "p`i'") ///
coeflabels(p`i' "`i'th percentile")
}

**# Table A.3: Full baseline results including controls
qui{
cap drop sample
reg demplsh dtariff $control90 emplsh90, robust
gen sample=(e(sample))
sum demplsh if e(sample)
estadd scalar mean = r(mean)
est store empl1
reg demplsh_m dtariff $control90 emplsh_m90, robust
sum demplsh_m if e(sample)
estadd scalar mean = r(mean)
est store empl_m1
reg demplsh_f dtariff $control90 emplsh_f90, robust
sum demplsh_f if e(sample)
estadd scalar mean = r(mean)
est store empl_f1
}

esttab empl1 empl_m1 empl_f1, ///
mtitles("All" "Male" "Female") star(* 0.10 ** 0.05 *** 0.01) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
stats(mean r2, fmt(%15.2fc %15.2fc) labels("Mean dependent (percentage points)" "R2"))

esttab empl1 empl_m1 empl_f1 ///
using "$tabledir/table_a3.rtf", replace ///
nomtitles noobs collabels("") ///
title("Table A.3: Full baseline results including controls") ///
star(* 0.10 ** 0.05 *** 0.01) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
stats(mean r2, fmt(%15.2fc %15.2fc) labels("Mean dependent (percentage points)" "R2")) ///
coeflabels(dtariff "Delta Import tariffs" ///
		 agrsh90 "1990 agricultural sector employment share" ///
		 tersh90 "1990 tertiary sector employment share" ///
		 soesh90 "1990 SOE employment share" ///
		 avlight90 "1990 night lights" ///
		 emplsh90 "1990 employment share" ///
		 emplsh_m90 "1990 male employment share" ///
		 emplsh_f90 "1990 female employment share" ///
         _cons "Constant")
		 
**# Table A.4: Import tariffs and prefecture-level employment rates 1990-2005, restricted sample
capture drop sample
reg demplsh8290 dtariff $control90 emplsh82, robust
gen sample=(e(sample))

qui{
reg demplsh dtariff $control90 emplsh90 if sample==1, robust
sum demplsh if e(sample)
estadd scalar mean = r(mean)
est store empl_sample
reg demplsh_m dtariff $control90 emplsh_m90 if sample==1, robust
sum demplsh_m if e(sample)
estadd scalar mean = r(mean)
est store empl_m_sample
reg demplsh_f dtariff $control90 emplsh_f90 if sample==1, robust
sum demplsh_f if e(sample)
estadd scalar mean = r(mean)
est store empl_f_sample

reg demplsh_m dtariff $control90 emplsh_m90 if sample==1
est store empl_m
reg demplsh_f dtariff $control90 emplsh_f90 if sample==1
est store empl_f
suest empl_m empl_f, robust

lincom [empl_m_mean]dtariff - [empl_f_mean]dtariff
scalar cof_dtariff=r(estimate)
scalar var_dtariff=r(se)^2

reg demplsh_m dtariff $control90 if sample==1
chcof
sum demplsh_mf if e(sample)
estadd scalar mean = r(mean)
est store empl_mf_sample
}

esttab empl_sample empl_m_sample empl_f_sample empl_mf_sample, ///
mtitles("All" "Male" "Female" "Male-Female Difference") star(* 0.10 ** 0.05 *** 0.01) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") keep(dtariff) ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"'))

esttab empl_sample empl_m_sample empl_f_sample empl_mf_sample ///
using "$tabledir/table_a4.rtf", replace ///
nomtitles noobs collabels("") ///
title("Table A.4: Import tariffs and prefecture-level employment rates 1990-2005, restricted sample") ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(dtariff) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"')) ///
coeflabels(dtariff "Delta Import tariffs")

**# Table A.5: Import tariffs and the expansion of education
qui{
reg dstush_m dtariff $control90 stush_m90, robust
sum dstush_m if e(sample)
estadd scalar mean = r(mean)
est store stush_m
reg dstush_f dtariff $control90 stush_f90, robust
sum dstush_f if e(sample)
estadd scalar mean = r(mean)
est store stush_f

reg dstush_m dtariff $control90 stush_m90
est store s_m
reg dstush_f dtariff $control90 stush_f90
est store s_f
suest s_m s_f, robust

lincom [s_m_mean]dtariff - [s_f_mean]dtariff
scalar cof_dtariff=r(estimate)
scalar var_dtariff=r(se)^2

reg dstush_m dtariff $control90
chcof
sum dstush_mf if e(sample)
estadd scalar mean = r(mean)
est store stush_mf
}
esttab stush_m stush_f stush_mf, ///
mtitles("Male" "Female" "Male-Female Difference") star(* 0.10 ** 0.05 *** 0.01) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") keep(dtariff) ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"'))

esttab stush_m stush_f stush_mf ///
using "$tabledir/table_a5.rtf", replace ///
nomtitles noobs collabels("") ///
title("Table A.5: Import tariffs and the expansion of education") ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(dtariff) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"')) ///
coeflabels(dtariff "Delta Import tariffs")

* Table A.6: Import tariffs and prefecture-level employment rates, tradable and non-tradable sectors

qui {
foreach sec in trade ntrade {
reg demplsh_`sec'_m dtariff $control90 emplsh_`sec'_m90, robust
sum demplsh_`sec'_m
estadd scalar mean = r(mean)
est store empl_m_`sec'

reg demplsh_`sec'_f dtariff $control90 emplsh_`sec'_f90, robust
sum demplsh_`sec'_f
estadd scalar mean = r(mean)
est store empl_f_`sec'

reg demplsh_`sec'_m dtariff $control90 emplsh_`sec'_m90
est store empl_m
reg demplsh_`sec'_f dtariff $control90 emplsh_`sec'_f90
est store empl_f
suest empl_m empl_f, robust

lincom [empl_m_mean]dtariff - [empl_f_mean]dtariff
scalar cof_dtariff=r(estimate)
scalar var_dtariff=r(se)^2


reg demplsh_`sec'_m dtariff $control90 emplsh_`sec'_m90
chcof
sum demplsh_`sec'_mf
estadd scalar mean = r(mean)
est store empl_`sec'
}
}

esttab empl_m_trade empl_f_trade empl_trade, ///
mtitles("Male" "Female" "Male-Female Difference") ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") keep(dtariff) ///
star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"'))

esttab empl_m_trade empl_f_trade empl_trade ///
using "$tabledir/table_a6.rtf",replace ///
mtitles("Male" "Female" "Male-Female Difference") noobs collabels("") ///
title("Panel A: Tradable sectors") ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(dtariff) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"')) ///
coeflabels(dtariff "Delta Import tariffs")

esttab empl_m_ntrade empl_f_ntrade empl_ntrade, ///
mtitles("Male" "Female" "Male-Female Difference") ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") keep(dtariff) ///
star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"'))

esttab empl_m_ntrade empl_f_ntrade empl_ntrade ///
using "$tabledir/table_a6.rtf",append ///
nomtitles eqlabels(none) noobs collabels("") nonumbers ///
title("Panel B: Non-tradable sectors") ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(dtariff) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"')) ///
coeflabels(dtariff "Delta Import tariffs")


**# Table A.7: Tariff rate reduction and changes in population and employment by gender
qui {
reg dlnpop_m dtariff $control90 lnpop_m90, robust
sum dlnpop_m
estadd scalar mean = r(mean)
est store lnpop_m
reg dlnpop_f dtariff $control90 lnpop_f90, robust
sum dlnpop_f
estadd scalar mean = r(mean)
est store lnpop_f

reg dlnpop_m dtariff $control90 lnpop_m90
est store pop_m
reg dlnpop_f dtariff $control90 lnpop_f90
est store pop_f
suest pop_m pop_f, robust

lincom [pop_m_mean]dtariff - [pop_f_mean]dtariff
scalar cof_dtariff=r(estimate)
scalar var_dtariff=r(se)^2

reg dlnpop_m dtariff $control90
chcof
sum dlnpop_mf
estadd scalar mean = r(mean)
est store lnpop_mf
}

esttab lnpop_m lnpop_f lnpop_mf, ///
mtitles("Male" "Female" "Male-Female Difference") ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") keep(dtariff) ///
star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"'))

esttab lnpop_m lnpop_f lnpop_mf ///
using "$tabledir/table_a7.rtf",replace ///
mtitles("Male" "Female" "Male-Female Difference") noobs collabels("") ///
title("Panel A: Dependent: Delta ln population") ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(dtariff) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"')) ///
coeflabels(dtariff "Delta Import tariffs")
		 
qui {
reg dlnempl_m dtariff $control90 lnempl_m90, robust
sum dlnempl_m
estadd scalar mean = r(mean)
est store lnempl_m
reg dlnempl_f dtariff $control90 lnempl_f90, robust
sum dlnempl_f
estadd scalar mean = r(mean)
est store lnempl_f

reg dlnempl_m dtariff $control90 lnempl_m90
est store empl_m
reg dlnempl_f dtariff $control90 lnempl_f90
est store empl_f
suest empl_m empl_f, robust

lincom [empl_m_mean]dtariff - [empl_f_mean]dtariff
scalar cof_dtariff=r(estimate)
scalar var_dtariff=r(se)^2

reg dlnempl_m dtariff $control90
chcof
sum dlnempl_mf
estadd scalar mean = r(mean)
est store lnempl_mf
}

esttab lnempl_m lnempl_f lnempl_mf, ///
mtitles("Male" "Female" "Male-Female Difference") ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") keep(dtariff) ///
star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"'))

esttab lnempl_m lnempl_f lnempl_mf ///
using "$tabledir/table_a7.rtf",append ///
nomtitles eqlabels(none) noobs collabels("") nonumbers ///
title("Panel B: Dependent: Delta ln employment") ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(dtariff) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
stats(mean, fmt(%15.2fc) labels(`"Mean dependent (percentage points)"')) ///
coeflabels(dtariff "Delta Import tariffs")

**# Table A.8: Tariff rates reduction and employment rate by gender: Robustness check controlling for changes in migrant share

cap program drop chcof_tab8
program chcof_tab8, eclass
tempname bmat
	matrix `bmat' = e(b)
	matrix `bmat'[1,1] = cof_dtariff
	matrix `bmat'[1,2] = cof_dpopsh_migr
	ereturn repost b = `bmat'
	
tempname semat
	matrix `semat' = e(V)
	matrix `semat'[1,1] = var_dtariff
	matrix `semat'[2,2] = var_dpopsh_migr
	ereturn repost V = `semat'
end

qui{
reg demplsh_m dtariff $control90 dpopsh_migr emplsh_m90, robust
est store empl_m_mig
reg demplsh_f dtariff $control90 dpopsh_migr emplsh_f90, robust
est store empl_f_mig

reg demplsh_m dtariff $control90 dpopsh_migr emplsh_m90
est store empl_m
reg demplsh_f dtariff $control90 dpopsh_migr emplsh_f90
est store empl_f
suest empl_m empl_f, robust

lincom [empl_m_mean]dtariff - [empl_f_mean]dtariff
scalar cof_dtariff=r(estimate)
scalar var_dtariff=r(se)^2
lincom [empl_m_mean]dpopsh_migr - [empl_f_mean]dpopsh_migr
scalar cof_dpopsh_migr=r(estimate)
scalar var_dpopsh_migr=r(se)^2

reg demplsh_m dtariff dpopsh_migr $control90
chcof_tab8
est store empl_mf_mig
}

esttab empl_m_mig empl_f_mig empl_mf_mig, ///
mtitles("Male" "Female" "Male-Female Difference") ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") keep(dtariff dpopsh_migr) ///
star(* 0.10 ** 0.05 *** 0.01)

esttab empl_m_mig empl_f_mig empl_mf_mig ///
using "$tabledir/table_a8.rtf",replace ///
mtitles("Male" "Female" "Male-Female Difference") noobs collabels("") ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(dtariff dpopsh_migr) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
stats() ///
coeflabels(dtariff "Delta Import tariffs" ///
           dpopsh_migr "Delta Migrant share")
		   
* Table A.10: Controlling for potential channels

* Full sample
capture program drop chcof_tab_a10a
program chcof_tab_a10a, eclass
tempname bmat
	matrix `bmat' = e(b)
	matrix `bmat'[1,1] = cof_dtariff
	matrix `bmat'[1,2] = cof_dfiss
	matrix `bmat'[1,3] = cof_ddisc	
	matrix `bmat'[1,4] = cof_dcompg
	matrix `bmat'[1,5] = cof_dlngdppc
	ereturn repost b = `bmat'
	
tempname semat
	matrix `semat' = e(V)
	matrix `semat'[1,1] = var_dtariff
	matrix `semat'[2,2] = var_dfiss
	matrix `semat'[3,3] = var_ddisc	
	matrix `semat'[4,4] = var_dcompg
	matrix `semat'[5,5] = var_dlngdppc
	ereturn repost V = `semat'
end

global channel "dfiss ddisc dcompg dlngdppc"
qui{
reg demplsh_m dtariff $channel $control90 emplsh_m90, robust
est store ch_all_m
reg demplsh_f dtariff $channel $control90 emplsh_f90, robust
est store ch_all_f

reg demplsh_m dtariff $channel $control90 emplsh_m90
est store empl_m
reg demplsh_f dtariff $channel $control90 emplsh_f90
est store empl_f
suest empl_m empl_f, robust

lincom [empl_m_mean]dtariff - [empl_f_mean]dtariff
scalar cof_dtariff=r(estimate)
scalar var_dtariff=r(se)^2

foreach ch in $channel {
lincom [empl_m_mean]`ch' - [empl_f_mean]`ch'
scalar cof_`ch'=r(estimate)
scalar var_`ch'=r(se)^2
}
reg demplsh_m dtariff $channel $control90 emplsh_m90
chcof_tab_a10a
est store ch_all_mf
}

* Non-SOEs
global channel_nsoe "dfiss_nsoe ddisc_nsoe dcompg_nsoe dlngdppc"
capture program drop chcof_tab_a10b
program chcof_tab_a10b, eclass
tempname bmat
	matrix `bmat' = e(b)
	matrix `bmat'[1,1] = cof_dtariff
	matrix `bmat'[1,2] = cof_dfiss_nsoe
	matrix `bmat'[1,3] = cof_ddisc_nsoe	
	matrix `bmat'[1,4] = cof_dcompg_nsoe
	matrix `bmat'[1,5] = cof_dlngdppc
	ereturn repost b = `bmat'
	
tempname semat
	matrix `semat' = e(V)
	matrix `semat'[1,1] = var_dtariff
	matrix `semat'[2,2] = var_dfiss_nsoe
	matrix `semat'[3,3] = var_ddisc_nsoe
	matrix `semat'[4,4] = var_dcompg_nsoe
	matrix `semat'[5,5] = var_dlngdppc
	ereturn repost V = `semat'
end

qui{
reg demplsh_m_nsoe9504 dtariff $channel_nsoe $control90 emplsh_m_nsoe95, robust
est store ch_nsoe_m
reg demplsh_f_nsoe9504 dtariff $channel_nsoe $control90 emplsh_f_nsoe95, robust
est store ch_nsoe_f
reg demplsh_m_nsoe9504 dtariff $channel_nsoe $control90 emplsh_m_nsoe95
est store empl_m
reg demplsh_f_nsoe9504 dtariff $channel_nsoe $control90 emplsh_f_nsoe95
est store empl_f
suest empl_m empl_f, robust

lincom [empl_m_mean]dtariff - [empl_f_mean]dtariff
scalar cof_dtariff=r(estimate)
scalar var_dtariff=r(se)^2

foreach ch in $channel_nsoe {
lincom [empl_m_mean]`ch' - [empl_f_mean]`ch'
scalar cof_`ch'=r(estimate)
scalar var_`ch'=r(se)^2
}
reg demplsh_m_nsoe9504 dtariff $channel_nsoe $control90 emplsh_m_nsoe95
chcof_tab_a10b
est store ch_nsoe_mf
}

esttab ch_all_m ch_all_f ch_all_mf ch_nsoe_m ch_nsoe_f ch_nsoe_mf, ///
mtitles("Male" "Female" "Male-Female Difference" "Male" "Female" "Male-Female Difference") ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
star(* 0.10 ** 0.05 *** 0.01) ///
rename(dfiss_nsoe "dfiss" ddisc_nsoe "ddisc" dcompg_nsoe "dcompg") ///
order(dtariff dfiss ddisc dcompg dlngdppc) ///
keep(dtariff $channel) stats() noobs

esttab ch_all_m ch_all_f ch_all_mf ch_nsoe_m ch_nsoe_f ch_nsoe_mf ///
using "$tabledir/table_a10.rtf",replace ///
mtitles("Male" "Female" "Male-Female Difference" "Male" "Female" "Male-Female Difference") noobs collabels("") ///
star(* 0.10 ** 0.05 *** 0.01) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
rename(dfiss_nsoe "dfiss" ddisc_nsoe "ddisc" dcompg_nsoe "dcompg") ///
order(dtariff dfiss ddisc dcompg dlngdppc) ///
keep(dtariff $channel) stats() ///
coeflabels(dtariff "Delta Import tariffs" ///
	       dfiss "Delta Share of female-intensive sectors" ///
	       ddisc "Delta Gender discrimination" ///
	       dcompg "Delta Computer intensity" ///	
	       dlngdppc "Delta Local GDP per capita")
	
* Table A.9: Import tariffs and individual probability of working
/* cap program drop chcof_tab_a9
program chcof_tab_a9, eclass
tempname bmat
	matrix `bmat' = e(b)
	matrix `bmat'[1,1] = cof_tariff
	ereturn repost b = `bmat'
	
tempname semat
	matrix `semat' = e(V)
	matrix `semat'[1,1] = var_tariff
	ereturn repost V = `semat'
end

use "$datadir/individual_data",clear
global control1 "age age2 i.edu_cat i.type i.migrant i.maritals hhsize i.hhhead i.ethnicity"
global control2 "c.agrsh90#i.year c.tersh90#i.year c.soesh90#i.year c.avlight90#i.year"

qui {
reghdfe empl tariff $control1 $control2 c.emplsh_m90#i.year [pw=perwt] if gender==1, absorb(city year) vce(cluster city)
sum empl if e(sample)
estadd scalar mean = r(mean)
est store full_male
reghdfe empl tariff $control1 $control2 c.emplsh_f90#i.year [pw=perwt] if gender==2, absorb(city year) vce(cluster city)
sum empl if e(sample)
estadd scalar mean = r(mean)
est store full_female

reg empl tariff $control1 $control2 c.emplsh_m90#i.year i.city i.year [iw=perwt] if gender==1
est store empl_m
reg empl tariff $control1 $control2 c.emplsh_f90#i.year i.city i.year [iw=perwt] if gender==2
est store empl_f
suest empl_m empl_f, vce(cluster city)

lincom [empl_m_mean]tariff - [empl_f_mean]tariff
scalar cof_tariff=r(estimate)
scalar var_tariff=r(se)^2

reghdfe empl tariff $control1 $control2 c.emplsh_m90#i.year [pw=perwt] if gender==1, absorb(city year)
chcof_tab_a9
est store full
}

esttab full_male full_female full, ///
mtitles("Male" "Female" "Male-Female Difference") ///
star(* 0.10 ** 0.05 *** 0.01) ///
cells("b(fmt(4)star)" "t(fmt(2)par abs)") ///
keep(tariff) ///
stats(mean N r2, fmt(%15.2fc %15.0fc %15.2fc) labels("Mean dependent" "Observations" "R2"))

esttab full_male full_female full ///
using "$tabledir/table_a9.rtf",replace ///
mtitles("Male" "Female" "Male-Female Difference") noobs collabels("") ///
star(* 0.10 ** 0.05 *** 0.01) ///
cells("b(fmt(4)star)" "t(fmt(2)par abs)") ///
keep(tariff) ///
stats(mean N r2, fmt(%15.2fc %15.0fc %15.2fc) labels("Mean dependent" "Observations" "R2")) ///
coeflabels(tariff "Import tariffs")

**# Table B.1: Import tariffs, firm-level markups, and changes in the number of new firms, 1995-2004

* Panel A: Dependent: Firm-level markup (in ln)
use "$datadir/firm_data",clear
qui {
reghdfe lnmarkup tariff i.year, absorb(city ind4d) vce(cluster city ind4d)
estadd local cityfe "Yes"
estadd local yearfe "Yes"
estadd local indfe "Yes"
est store mkup
reghdfe lnmarkup tariff i.year if ownsh==1, absorb(city ind4d) vce(cluster city ind4d)
estadd local cityfe "Yes"
estadd local yearfe "Yes"
estadd local indfe "Yes"
est store mkup_soe
reghdfe lnmarkup tariff i.year if ownsh==2, absorb(city ind4d) vce(cluster city ind4d)
estadd local cityfe "Yes"
estadd local yearfe "Yes"
estadd local indfe "Yes"
est store mkup_nsoe
}

esttab mkup mkup_soe mkup_nsoe, ///
mtitles("All firms" "SOEs" "Non-SOEs") ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") keep(tariff) ///
star(* 0.10 ** 0.05 *** 0.01)

esttab mkup mkup_soe mkup_nsoe ///
using "$tabledir/table_b1.rtf",replace ///
mtitles("All firms" "SOEs" "Non-SOEs") noobs collabels("") ///
title("Panel A: Dependent: Firm-level markup (in ln)") ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(tariff) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
stats(cityfe indfe yearfe N r2, fmt(0 0 0 %15.0fc %15.2fc)labels("Prefecture FE" "Four-digit industry FE" "Year FE" "Observations" "R2")) ///
coeflabels(tariff "Import tariffs")
	 
* Panel B: Dependent: Change in the number of new firms (in ln)
use "$datadir/regdata.dta",clear
global control95 "agrsh95 tersh95 soesh95 avlight95"

qui {
reg dln_nfirm dtariff_imp9504 $control95 ln_nfirm95, robust
sum dln_nfirm
estadd scalar mean = r(mean)
est store nfirm
reg dln_nfirm_soe dtariff_imp9504 $control95 ln_nfirm_soe95, robust
sum dln_nfirm_soe
estadd scalar mean = r(mean)
est store nfirm_soe
reg dln_nfirm_nsoe dtariff_imp9504 $control95 ln_nfirm_nsoe95, robust
sum dln_nfirm_nsoe
estadd scalar mean = r(mean)
est store nfirm_nsoe
}

esttab nfirm nfirm_soe nfirm_nsoe, ///
mtitles("All firms" "SOEs" "Non-SOEs") ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") keep(dtariff_imp9504) ///
star(* 0.10 ** 0.05 *** 0.01) ///
stats(N r2, fmt(0 %15.2fc) labels("Observations" "R2"))

esttab nfirm nfirm_soe nfirm_nsoe ///
using "$tabledir/table_b1.rtf",append ///
nomtitles eqlabels(none) noobs collabels("") nonumbers ///
title("Panel B: Dependent: Change in the number of new firms (in ln)") ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(dtariff_imp9504) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
stats(N r2, fmt(0 %15.2fc) labels("Observations" "R2")) ///
coeflabels(dtariff_imp9504 "Delta Import tariffs")

* Panel C: Dependent: Change in the total number of firms (in ln)
qui {	 
reg dln_fnum dtariff_imp9504 $control95 ln_fnum95, robust
sum dln_fnum
estadd scalar mean = r(mean)
est store fnum
reg dln_fnum_soe dtariff_imp9504 $control95 ln_fnum_soe95, robust
sum dln_fnum_soe
estadd scalar mean = r(mean)
est store fnum_soe
reg dln_fnum_nsoe dtariff_imp9504 $control95 ln_fnum_nsoe95, robust
sum dln_fnum_nsoe
estadd scalar mean = r(mean)
est store fnum_nsoe
}

esttab fnum fnum_soe fnum_nsoe, ///
mtitles("All firms" "SOEs" "Non-SOEs") ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") keep(dtariff_imp9504) ///
star(* 0.10 ** 0.05 *** 0.01) ///
stats(N r2, fmt(0 %15.2fc) labels("Observations" "R2"))

esttab fnum fnum_soe fnum_nsoe ///
using "$tabledir/table_b1.rtf",append ///
nomtitles eqlabels(none) noobs collabels("") nonumbers ///
title("Panel C: Dependent: Change in the total number of firms (in ln)") ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(dtariff_imp9504) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
stats(N r2, fmt(0 %15.2fc) labels("Observations" "R2")) ///
coeflabels(dtariff_imp9504 "Delta Import tariffs")

* Panel D: Coefficient difference between Panel B and Panel C
capture program drop chcof_tab_b1
program chcof_tab_b1, eclass
tempname bmat
	matrix `bmat' = e(b)
	matrix `bmat'[1,1] = cof_dtariff_imp9504
	ereturn repost b = `bmat'
	
tempname semat
	matrix `semat' = e(V)
	matrix `semat'[1,1] = var_dtariff_imp9504
	ereturn repost V = `semat'
end

qui {
reg dln_nfirm dtariff_imp9504 $control95 ln_nfirm95
est store nfirm
reg dln_fnum dtariff_imp9504 $control95 ln_fnum95
est store fnum
suest nfirm fnum, robust

lincom [nfirm_mean]dtariff_imp9504 - [fnum_mean]dtariff_imp9504
scalar cof_dtariff_imp9504=r(estimate)
scalar var_dtariff_imp9504=r(se)^2
reg dln_fnum dtariff_imp9504 $control95 ln_fnum95
chcof_tab_b1
est store efirm

reg dln_nfirm_nsoe dtariff_imp9504 $control95 ln_nfirm_nsoe95
est store nfirm_nsoe
reg dln_fnum_nsoe dtariff_imp9504 $control95 ln_fnum_nsoe95
est store fnum_nsoe
suest nfirm_nsoe fnum_nsoe, robust

lincom [nfirm_nsoe_mean]dtariff_imp9504 - [fnum_nsoe_mean]dtariff_imp9504
scalar cof_dtariff_imp9504=r(estimate)
scalar var_dtariff_imp9504=r(se)^2
reg dln_fnum dtariff_imp9504 $control95 ln_fnum95
chcof_tab_b1
est store efirm_nsoe

reg dln_nfirm_soe dtariff_imp9504 $control95 ln_nfirm_soe95
est store nfirm_soe
reg dln_fnum_soe dtariff_imp9504 $control95 ln_fnum_soe95
est store fnum_soe
suest nfirm_soe fnum_soe, robust

lincom [nfirm_soe_mean]dtariff_imp9504 - [fnum_soe_mean]dtariff_imp9504
scalar cof_dtariff_imp9504=r(estimate)
scalar var_dtariff_imp9504=r(se)^2
reg dln_fnum dtariff_imp9504 $control95 ln_fnum95
chcof_tab_b1
est store efirm_soe
}

esttab efirm efirm_soe efirm_nsoe, ///
mtitles("All firms" "SOEs" "Non-SOEs") ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") keep(dtariff_imp9504) ///
star(* 0.10 ** 0.05 *** 0.01)

esttab efirm efirm_soe efirm_nsoe ///
using "$tabledir/table_b1.rtf",append ///
nomtitles eqlabels(none) noobs collabels("") nonumbers ///
title("Panel D: Coefficient difference between Panel B and Panel C") ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(dtariff_imp9504) ///
cells("b(fmt(2)star)" "t(fmt(2)par abs)") ///
stats() ///
coeflabels(dtariff_imp9504 "Delta Import tariffs")*/
