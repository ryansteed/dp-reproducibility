
*** This do-file creates the final data used by Lundqvist, Dahlberg and M�rk: Stimulating Local Public Employment: Do General Grants Work? ***

*Change to desired directory:
cd "."

***

foreach file in IFAU_pers outsourced_pers {
use "`file'.dta", clear
sort code year
save, replace
}

use "municipaldata.dta", clear
sort code year
merge 1:1 code year using "IFAU_pers.dta"
drop _merge
merge 1:1 code year using "outsourced_pers.dta"
drop _merge

gen migrationgrant=0
replace migrationgrant=(popchange_10y+2)*100 if popchange_10y<=-2
replace migrationgrant=abs(migrationgrant)
replace migrationgrant=round(migrationgrant)

gen migpop=migrationgrant*pop_1
sort year
by year: egen summigpop=sum(migpop)
by year: egen sumpop=sum(pop_1)
gen migrationmean=summigpop/sumpop

replace migrationgrant=(migrationgrant-migrationmean)/100

*Drop municipalities involved in mergers and municipalities handling different things:
* Nykvarn (140)
* S�dertalje (181)
* Knivsta (330)
* Uppsala (380)
* Gotland (980)
* Malm� (1280)
* G�teborg (1480)
* Bollebygd (1443)
* Bor�s (1490)
* Lekeberg (1814)
* �rebro (1880)
drop if code == 140 | code == 181 | code == 330 | code == 380 | code == 980 | code == 1280 | code == 1480 | code == 1443 | code == 1490 | code == 1814 | code == 1880

*Hypothetical wage costs (see Table 4)
foreach outcome in total admin child school elder social tech {
sum wage_`outcome'
local wage=r(mean)
gen exp_`outcome'=12*(pers_`outcome'*`wage'/(100*1000))
label var exp_`outcome' "Annual expenditures on personnel in 100SEK/capita"
}
*Add payroll taxes:
foreach outcome in total admin child school elder social tech {
replace exp_`outcome'=1.3*exp_`outcome'
}

foreach outcome in total admin child school elder social tech {
gen expshare_`outcome'=exp_`outcome'*100/expenditures_total
}

****************************************************************************

*Create control functions in the forcing variable

gen outmigration=-popchange_10y
replace outmigration=round(outmigration,.01)
gen forcing=outmigration-2
gen D=(outmigration>2)
gen Dforcing1=D*forcing
replace Dforcing1 = round(Dforcing1)

forvalues i=1/3 {
	gen forcing`i'=forcing^(`i')
	}

*Different bandwidths, h

foreach i in 5 10 15 {
	gen h`i'=0
	replace h`i'=1 if forcing>=-`i' & forcing<=`i'
	}


****************************************************************************
save "finaldata.dta", replace
****************************************************************************
