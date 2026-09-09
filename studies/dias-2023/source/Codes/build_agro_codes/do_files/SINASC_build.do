********************************************************************************
* Build: Births
********************************************************************************


clear*
set more off , permanently

use "${datasus}/SINASC_micro.dta", clear
count // 54,095,594


* Restrict sample and variables
drop if ano<1998 | ano>2010




********************************************************************************
* Handling birth outcomes
gen births=1
rename d_pc birth_csection
gen birth_lowbirthw=(peso<2500)
gen birth_vlowbirthw=(peso<1500)
replace birth_lowbirthw=. if peso==.
replace birth_vlowbirthw=. if peso==.

gen lowapgar1=(apgar1<=7)
gen lowapgar5=(apgar5<=7)
gen vlowapgar1=(apgar1<7)
gen vlowapgar5=(apgar5<7)
replace lowapgar1=. if apgar1==.
replace lowapgar5=. if apgar5==.
replace vlowapgar1=. if apgar1==.
replace vlowapgar5=. if apgar5==.

rename d_fem birth_female
gen birth_weekspreg_37plus =(nsemgint==5 | nsemgint==6)
replace birth_weekspreg_37plus=. if nsemgint==.

gen gesta_below22 = (nsemgint==1)
gen gesta_22_27 = (nsemgint==2)
gen gesta_28_36 = (nsemgint==3)
gen gesta_37_41 = (nsemgint==5)
gen gesta_above42 = (nsemgint==6)
gen gesta_missing = (nsemgint==.)

rename d_anom birth_anom

gen birth_single=(tpgra==1)
replace birth_single=. if tpgra==.
gen birth_twin=(tpgra==2)
replace birth_twin=. if tpgra==.
gen birth_mult=(tpgra==3)
replace birth_mult=. if tpgra==.

********************************************************************************
* Access to prenatal and health services
gen birth_prenatal_0to6=(nconsint==1 | nconsint==2 | nconsint==3 | nconsint==8 )
gen birth_prenatal_7plus=(nconsint==4)
foreach i in birth_prenatal_0to6 birth_prenatal_7plus {
replace `i'=. if nconsint==. 
}
*



********************************************************************************
* Mothers' characteristics
rename idade birth_motherage
gen birth_motherage_17below=(birth_motherage>=11 & birth_motherage<=17)
gen birth_motherage_1019=(birth_motherage>=10 & birth_motherage<=19)
gen birth_motherage_18_24=(birth_motherage>=18 & birth_motherage<=24)
gen birth_motherage_25_34=(birth_motherage>=25 & birth_motherage<=34) 
gen birth_motherage_35_44=(birth_motherage>=35 & birth_motherage<=44) 
foreach i in birth_motherage_17below birth_motherage_1019 birth_motherage_18_24 birth_motherage_25_34 birth_motherage_35_44 {
replace `i'=. if  birth_motherage==.
}
gen birth_motheredclow=(escm==1 | escm==2)
replace birth_motheredclow=. if escm==.

gen birth_motheredcmid=(escm==3)
replace birth_motheredcmid=. if escm==.

gen birth_motheredchigh=(escm==4 | escm==5)
replace birth_motheredchigh=. if escm==.

gen birth_motheredcvlow=(escm==1)
replace birth_motheredcvlow=. if escm==.

gen birth_motheredcvhigh=(escm==5)
replace birth_motheredcvhigh=. if escm==.

* "Continuous" measure: midpoint for bounded intervals, 12 for 12+
gen birth_motheredccont = .
replace birth_motheredccont = 0 if escm==1
replace birth_motheredccont = 2 if escm==2
replace birth_motheredccont = 6 if escm==3
replace birth_motheredccont = 9.5 if escm==4
replace birth_motheredccont = 12 if escm==5

* Previous deliveries and previous abortions/fetal deaths
rename qtfilv birth_motherdel
rename qtfilm birth_motherabt


********************************************************************************
* Save and collapse


rename mun_res code_mun
rename ano year


collapse (sum) birth* lowapgar1 lowapgar5 vlowapgar1 vlowapgar5 (mean) birth_motherdelmean=birth_motherdel birth_motherabtmean=birth_motherabt birth_motheredccont_mean=birth_motheredccont birth_motheredcmid_mean=birth_motheredcmid birth_motheredclow_mean=birth_motheredclow birth_motheredcvlow_mean=birth_motheredcvlow birth_motheredchigh_mean=birth_motheredchigh birth_motheredcvhigh_mean=birth_motheredcvhigh birth_motherage_mean=birth_motherage apgar1_mean=apgar1 apgar5_mean=apgar5 peso_mean=peso gesta_below22 gesta_22_27 gesta_28_36 gesta_37_41 gesta_above42 gesta_missing, by(year code_mun)
drop birth_motherage
compress
save "$pathfiles_data/Workfiles/SINASC_year.dta", replace
