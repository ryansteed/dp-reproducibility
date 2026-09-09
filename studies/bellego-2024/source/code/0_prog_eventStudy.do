/* Inputs :
	- varlist : liste des outcomes ànalyser. Le graph aura une courbe par 
	outcome
	- min / max : fenêtre temporelle. min doit être négatif et max positif.
	- event : nom de la variable qui code le temps depuis l'évènement
	- panvars : deux variables définissant le panel (individu et temps)
	- inter : variable avec laquelle interagir le temps depuis l'évènement. Si 
	elle est spécifiée, le graph aura autant de courbes que de niveaux de "inter".
	- altnorm : demande une normalisation à la Deaton des dummies. Au lieu d'en
	mettre deux à zéro, on impose qu'elles soient orthogonales à une tendance 
	temporelle et qu'elles somment à zéro.
	- les autres options sont passées à coefplot
*/

*** OLS event study : Drop the coef (dummy) where k=min and k=-1 
cap prog drop eventStudy
prog def eventStudy
	syntax varlist [if] [pw], min(integer) max(integer) Event(varname) PANvars(varlist) ///
		[Inter(varname) ALTnorm *]
	marksample touse
	loc pw = cond("`weight'"=="","","[`weight'`exp']")
	* Setup the panel
	cap xtset
	if _rc==0 {
		loc oldpanvars `"`r(panelvar)' `r(timevar)'"'
		xtset, clear
	}
	xtset `panvars'
	loc timevar "`r(timevar)'"
	loc idvar "`r(panelvar)'"
	* Generate discrete event variables
	tempvar ts
	qui su `event'
	qui egen `ts' = cut(`event'), at(`min'/`=`max'+1') ic
	qui tab `ts', g(_I_`ts')
	forv j=0/`=`max'-`min'' {
		loc xlabs `"`xlabs' `=`j'+1' "`=`min'+`j''""'
	}
	* Usefull dummy numbers and dummy sets
	loc dm1 = -`min' // Last dummy before event - will be set to zero
	loc dm2 = `dm1' - 1
	loc d0 = `dm1' + 1
	loc dl = `max'-`min'+1
	loc pre = `"_I_`ts'2-_I_`ts'`dm2'"'
	loc post = `"_I_`ts'`d0'-_I_`ts'`dl'"'
	* If Deaton's normalization is requested
	* (attention à ce que cela veut dire quand on demande une interaction)
	if "`altnorm'"!="" {
		qui replace _I_`ts'1 = (_I_`ts'1 - _I_`ts'`dm1') / (`min'+1)
		qui replace _I_`ts'`dm1' = _I_`ts'`dm1' + _I_`ts'1
		forv j=2/`dm2' {
			qui replace _I_`ts'`j' = _I_`ts'`j'-(`min'+`j'-1)*_I_`ts'1 - _I_`ts'`dm1'
		}
	}
	* Estimation
	eststo clear
	loc grlist `""'
	loc cntv 1
	cap qui levelsof `inter', loc(intlvl)
	cap loc intfl : word 1 of `intlvl'
	loc intnl = cond("`inter'"=="",1,`: word count `intlvl'')
	loc nvar : word count `varlist'
	spmap_color Dark2 `=max(2,`nvar'*`intnl')'
	loc colors = cond(`nvar'*`intnl'>1,`"`s(colors)'"',"black")
	loc leg `""'
	foreach v of varlist `varlist' {
		if "`inter'"=="" { // No interaction variable
			#d;
			loc grlist `"`grlist' (est`cntv' , lc("`col'") ciopts(lc("`col'") 
				recast(rline) lp(-)) keep(*`ts'*))"';
			#d cr
			loc col : word `cntv' of `colors'
			eststo: xtreg `v' i.`timevar' o._I_`ts'1 `pre' o._I_`ts'`dm1' `post'  ///
				if `touse' & inrange(`event',`min',`max') `pw', fe cluster(`idvar') allbase
			testparm `pre'
			testparm `post'
			loc leg `"`leg' lab(`=2*`cntv'' "`:var la `v''")"'
		}
		else { // Interaction variable
			loc cnti 0
			eststo: xtreg `v' i.`timevar' o._I_`ts'1 c.(`pre')#ibn.`inter' ///
				o._I_`ts'`dm1' c.(`post')#ibn.`inter' ///
				if `touse' & inrange(`event',`min',`max') `pw', fe cluster(`idvar') allbase
			foreach l of local intlvl {
				testparm `l'.`inter'#c.(`pre')
				loc ngr = (`cntv'-1)*`intnl'+`cnti'+1
				loc col : word `ngr' of `colors'
				#d;
				loc grlist `"`grlist' (est`cntv', lc("`col'") ciopts(lc("`col'") 
					recast(rline) lp(-))
					keep(`l'.`inter'#*`ts'* _I_`ts'*) rename(`l'.`inter'*=`intfl'.`inter'))"';
				#d cr
				loc `++cnti'
				loc leg `"`leg' lab(`=2*`ngr'' "`:var la `v'' - `:lab (`inter') `l''")"'
			}
		}
		loc `++cntv'
	}
	* Plot
	loc legon = cond(`nvar'*`intnl'>1,"legend(on)","legend(off)")
	coefplot `grlist', legend(pos(6) `leg' c(1)) `legon' ///
		vertical scheme(sgk_base) recast(line) lp(l) offset(0) base omit  ///
		graphregion(color(white)) bgcolor(white) /// yscale(r(-1.5 1)) ylabel(-1.5(.5)1) ///
		xti("`:var la `event''") xline(`=-`min'+1') xlab(`xlabs', alt)  `options'
	* Restore old panel settings
	if "`oldpanvars'"!="" {
		xtset `oldpanvars'
	}
	* Cleanup
	drop _I_`ts'*
end


*** OLS event study : Drop the coef (dummy) where k=-1 
cap prog drop eventStudy_alt
prog def eventStudy_alt
	syntax varlist [if] [pw], min(integer) max(integer) Event(varname) PANvars(varlist) ///
		[Inter(varname) ALTnorm *]
	marksample touse
	loc pw = cond("`weight'"=="","","[`weight'`exp']")
	* Setup the panel
	cap xtset
	if _rc==0 {
		loc oldpanvars `"`r(panelvar)' `r(timevar)'"'
		xtset, clear
	}
	xtset `panvars'
	loc timevar "`r(timevar)'"
	loc idvar "`r(panelvar)'"
	* Generate discrete event variables
	tempvar ts
	qui su `event'
	qui egen `ts' = cut(`event'), at(`min'/`=`max'+1') ic
	qui tab `ts', g(_I_`ts')
	forv j=0/`=`max'-`min'' {
		loc xlabs `"`xlabs' `=`j'+1' "`=`min'+`j''""'
	}
	* Usefull dummy numbers and dummy sets
	loc dm1 = -`min' // Last dummy before event - will be set to zero
	loc dm2 = `dm1' - 1
	loc d0 = `dm1' + 1
	loc dl = `max'-`min'+1
	loc pre = `"_I_`ts'1-_I_`ts'`dm2'"'
	loc post = `"_I_`ts'`d0'-_I_`ts'`dl'"'
	loc pre_bis = `"_I_`ts'2-_I_`ts'`dm2'"'
	* If Deaton's normalization is requested
	* (attention à ce que cela veut dire quand on demande une interaction)

	* Estimation
	eststo clear
	loc grlist `""'
	loc cntv 1
	cap qui levelsof `inter', loc(intlvl)
	cap loc intfl : word 1 of `intlvl'
	loc intnl = cond("`inter'"=="",1,`: word count `intlvl'')
	loc nvar : word count `varlist'
	spmap_color Dark2 `=max(2,`nvar'*`intnl')'
	loc colors = cond(`nvar'*`intnl'>1,`"`s(colors)'"',"black")
	loc leg `""'
	foreach v of varlist `varlist' {
		if "`inter'"=="" { // No interaction variable
			#d;
			loc grlist `"`grlist' (est`cntv' , lc("`col'") ciopts(lc("`col'") 
				recast(rline) lp(-)) keep(*`ts'*))"';
			#d cr
			loc col : word `cntv' of `colors'
			eststo: xtreg `v' i.`timevar' `pre' o._I_`ts'`dm1' `post'  ///
				if `touse' & inrange(`event',`min',`max') `pw', fe cluster(`idvar') allbase
			testparm `pre_bis'
			testparm `post'
			loc leg `"`leg' lab(`=2*`cntv'' "`:var la `v''")"'
		}
		else { // Interaction variable
			loc cnti 0
			eststo: xtreg `v' i.`timevar'  c.(`pre')#ibn.`inter' ///
				o._I_`ts'`dm1' c.(`post')#ibn.`inter' ///
				if `touse' & inrange(`event',`min',`max') `pw', fe cluster(`idvar') allbase
			foreach l of local intlvl {
				testparm `l'.`inter'#c.(`pre')
				loc ngr = (`cntv'-1)*`intnl'+`cnti'+1
				loc col : word `ngr' of `colors'
				#d;
				loc grlist `"`grlist' (est`cntv', lc("`col'") ciopts(lc("`col'") 
					recast(rline) lp(-))
					keep(`l'.`inter'#*`ts'* _I_`ts'*) rename(`l'.`inter'*=`intfl'.`inter'))"';
				#d cr
				loc `++cnti'
				loc leg `"`leg' lab(`=2*`ngr'' "`:var la `v'' - `:lab (`inter') `l''")"'
			}
		}
		loc `++cntv'
	}
	* Plot
	loc legon = cond(`nvar'*`intnl'>1,"legend(on)","legend(off)")
	coefplot `grlist', legend(pos(6) `leg' c(1)) `legon' ///
		vertical scheme(sgk_base) recast(line) lp(l) offset(0) base omit  ///
		graphregion(color(white)) bgcolor(white)  /// yscale(r(-0.5 0.5)) ylabel(-0.5(.5)0.5)
		xti("`:var la `event''") xline(`=-`min'+1') xlab(`xlabs', alt)  `options'
	* Restore old panel settings
	if "`oldpanvars'"!="" {
		xtset `oldpanvars'
	}
	* Cleanup
	drop _I_`ts'*
end


*** Negative Binomial event study : Drop the coef (dummy) where k=-1
cap prog drop PoissonEventStudy_alt
prog def PoissonEventStudy_alt
	syntax varlist [if] [pw], min(integer) max(integer) Event(varname) PANvars(varlist) ///
		[Inter(varname) ALTnorm *]
	marksample touse
	loc pw = cond("`weight'"=="","","[`weight'`exp']")
	* Setup the panel
	cap xtset
	if _rc==0 {
		loc oldpanvars `"`r(panelvar)' `r(timevar)'"'
		xtset, clear
	}
	xtset `panvars'
	loc timevar "`r(timevar)'"
	loc idvar "`r(panelvar)'"
	* Generate discrete event variables
	tempvar ts
	qui su `event'
	qui egen `ts' = cut(`event'), at(`min'/`=`max'+1') ic
	qui tab `ts', g(_I_`ts')
	forv j=0/`=`max'-`min'' {
		loc xlabs `"`xlabs' `=`j'+1' "`=`min'+`j''""'
	}
	* Usefull dummy numbers and dummy sets
	loc dm1 = -`min' // Last dummy before event - will be set to zero
	loc dm2 = `dm1' - 1
	loc d0 = `dm1' + 1
	loc dl = `max'-`min'+1
	loc pre = `"_I_`ts'1-_I_`ts'`dm2'"'
	loc post = `"_I_`ts'`d0'-_I_`ts'`dl'"'
	loc pre_bis = `"_I_`ts'2-_I_`ts'`dm2'"'
	* If Deaton's normalization is requested
	* (attention à ce que cela veut dire quand on demande une interaction)
	if "`altnorm'"!="" {
		qui replace _I_`ts'1 = (_I_`ts'1 - _I_`ts'`dm1') / (`min'+1)
		qui replace _I_`ts'`dm1' = _I_`ts'`dm1' + _I_`ts'1
		forv j=2/`dm2' {
			qui replace _I_`ts'`j' = _I_`ts'`j'-(`min'+`j'-1)*_I_`ts'1 - _I_`ts'`dm1'
		}
	}
	* Estimation
	eststo clear
	loc grlist `""'
	loc cntv 1
	cap qui levelsof `inter', loc(intlvl)
	cap loc intfl : word 1 of `intlvl'
	loc intnl = cond("`inter'"=="",1,`: word count `intlvl'')
	loc nvar : word count `varlist'
	spmap_color Dark2 `=max(2,`nvar'*`intnl')'
	loc colors = cond(`nvar'*`intnl'>1,`"`s(colors)'"',"black")
	loc leg `""'
	foreach v of varlist `varlist' {
		if "`inter'"=="" { // No interaction variable
			#d;
			loc grlist `"`grlist' (est`cntv' , lc("`col'") ciopts(lc("`col'") 
				recast(rline) lp(-)) keep(*`ts'*))"';
			#d cr
			loc col : word `cntv' of `colors'
			eststo: nbreg `v' i.`timevar' i.`idvar' `pre' o._I_`ts'`dm1' `post'  ///
				if `touse' & inrange(`event',`min',`max') `pw', vce(cluster `idvar') allbase
			testparm `pre'
			testparm `post'
			loc leg `"`leg' lab(`=2*`cntv'' "`:var la `v''")"'
		}
		else { // Interaction variable
			loc cnti 0
			eststo: nbreg `v' i.`timevar' i.`idvar' o._I_`ts'1 c.(`pre')#ibn.`inter' ///
				o._I_`ts'`dm1' c.(`post')#ibn.`inter' ///
				if `touse' & inrange(`event',`min',`max') `pw', vce (cluster `idvar') allbase
			foreach l of local intlvl {
				testparm `l'.`inter'#c.(`pre')
				loc ngr = (`cntv'-1)*`intnl'+`cnti'+1
				loc col : word `ngr' of `colors'
				#d;
				loc grlist `"`grlist' (est`cntv', lc("`col'") ciopts(lc("`col'") 
					recast(rline) lp(-))
					keep(`l'.`inter'#*`ts'* _I_`ts'*) rename(`l'.`inter'*=`intfl'.`inter'))"';
				#d cr
				loc `++cnti'
				loc leg `"`leg' lab(`=2*`ngr'' "`:var la `v'' - `:lab (`inter') `l''")"'
			}
		}
		loc `++cntv'
	}
	* Plot
	loc legon = cond(`nvar'*`intnl'>1,"legend(on)","legend(off)")
	coefplot `grlist', legend(pos(6) `leg' c(1)) `legon' ///
		vertical scheme(sgk_base) recast(line) lp(l) offset(0) base omit  ///
		graphregion(color(white)) bgcolor(white) ///
		xti("`:var la `event''") xline(`=-`min'+1') xlab(`xlabs', alt)  `options'
	* Restore old panel settings
	if "`oldpanvars'"!="" {
		xtset `oldpanvars'
	}
	* Cleanup
	drop _I_`ts'*
end



*** Negative Binomial event study : Drop the coef (dummy) where k=-1 and k=min
cap prog drop PoissonEventStudy
prog def PoissonEventStudy
	syntax varlist [if] [pw], min(integer) max(integer) Event(varname) PANvars(varlist) ///
		[Inter(varname) ALTnorm *]
	marksample touse
	loc pw = cond("`weight'"=="","","[`weight'`exp']")
	* Setup the panel
	cap xtset
	if _rc==0 {
		loc oldpanvars `"`r(panelvar)' `r(timevar)'"'
		xtset, clear
	}
	xtset `panvars'
	loc timevar "`r(timevar)'"
	loc idvar "`r(panelvar)'"
	* Generate discrete event variables
	tempvar ts
	qui su `event'
	qui egen `ts' = cut(`event'), at(`min'/`=`max'+1') ic
	qui tab `ts', g(_I_`ts')
	forv j=0/`=`max'-`min'' {
		loc xlabs `"`xlabs' `=`j'+1' "`=`min'+`j''""'
	}
	* Usefull dummy numbers and dummy sets
	loc dm1 = -`min' // Last dummy before event - will be set to zero
	loc dm2 = `dm1' - 1
	loc d0 = `dm1' + 1
	loc dl = `max'-`min'+1
	loc pre = `"_I_`ts'2-_I_`ts'`dm2'"'
	loc post = `"_I_`ts'`d0'-_I_`ts'`dl'"'
	* If Deaton's normalization is requested
	* (attention à ce que cela veut dire quand on demande une interaction)
	if "`altnorm'"!="" {
		qui replace _I_`ts'1 = (_I_`ts'1 - _I_`ts'`dm1') / (`min'+1)
		qui replace _I_`ts'`dm1' = _I_`ts'`dm1' + _I_`ts'1
		forv j=2/`dm2' {
			qui replace _I_`ts'`j' = _I_`ts'`j'-(`min'+`j'-1)*_I_`ts'1 - _I_`ts'`dm1'
		}
	}
	* Estimation
	eststo clear
	loc grlist `""'
	loc cntv 1
	cap qui levelsof `inter', loc(intlvl)
	cap loc intfl : word 1 of `intlvl'
	loc intnl = cond("`inter'"=="",1,`: word count `intlvl'')
	loc nvar : word count `varlist'
	spmap_color Dark2 `=max(2,`nvar'*`intnl')'
	loc colors = cond(`nvar'*`intnl'>1,`"`s(colors)'"',"black")
	loc leg `""'
	foreach v of varlist `varlist' {
		if "`inter'"=="" { // No interaction variable
			#d;
			loc grlist `"`grlist' (est`cntv' , lc("`col'") ciopts(lc("`col'") 
				recast(rline) lp(-)) keep(*`ts'*))"';
			#d cr
			loc col : word `cntv' of `colors'
			eststo: nbreg `v' i.`timevar' i.`idvar' o._I_`ts'1 `pre' o._I_`ts'`dm1' `post'  ///
				if `touse' & inrange(`event',`min',`max') `pw', vce(cluster `idvar') allbase
			testparm `pre'
			testparm `post'
			loc leg `"`leg' lab(`=2*`cntv'' "`:var la `v''")"'
		}
		else { // Interaction variable
			loc cnti 0
			eststo: nbreg `v' i.`timevar' i.`idvar' o._I_`ts'1 c.(`pre')#ibn.`inter' ///
				o._I_`ts'`dm1' c.(`post')#ibn.`inter' ///
				if `touse' & inrange(`event',`min',`max') `pw', vce (cluster `idvar') allbase
			foreach l of local intlvl {
				testparm `l'.`inter'#c.(`pre')
				loc ngr = (`cntv'-1)*`intnl'+`cnti'+1
				loc col : word `ngr' of `colors'
				#d;
				loc grlist `"`grlist' (est`cntv', lc("`col'") ciopts(lc("`col'") 
					recast(rline) lp(-))
					keep(`l'.`inter'#*`ts'* _I_`ts'*) rename(`l'.`inter'*=`intfl'.`inter'))"';
				#d cr
				loc `++cnti'
				loc leg `"`leg' lab(`=2*`ngr'' "`:var la `v'' - `:lab (`inter') `l''")"'
			}
		}
		loc `++cntv'
	}
	* Plot
	loc legon = cond(`nvar'*`intnl'>1,"legend(on)","legend(off)")
	coefplot `grlist', legend(pos(6) `leg' c(1)) `legon' ///
		vertical scheme(sgk_base) recast(line) lp(l) offset(0) base omit  ///
		graphregion(color(white)) bgcolor(white) ///
		xti("`:var la `event''") xline(`=-`min'+1') xlab(`xlabs', alt)  `options'
	* Restore old panel settings
	if "`oldpanvars'"!="" {
		xtset `oldpanvars'
	}
	* Cleanup
	drop _I_`ts'*
end



