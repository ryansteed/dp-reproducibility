
preserve

est clear

local vars = "hp_growth_real deltaP units_growth"
gen deltaP_00_06 = deltaP

foreach var of local vars {

reg `var'_00_06 land_aval [aw=pop_18_33_00], cluster(statefip)
 local F = (_b[land_aval]/_se[land_aval])^2
 post_param "Fstat" `F'
 est store `var'a2

reg `var'_00_06 land_aval $controls [aw=pop_18_33_00], cluster(statefip)
 local F = (_b[land_aval]/_se[land_aval])^2
 post_param "Fstat" `F'
 est store `var'a2b

reg `var'_06_11 land_aval [aw=pop_18_33_00], cluster(statefip)
 local F = (_b[land_aval]/_se[land_aval])^2
 post_param "Fstat" `F'
 est store `var'a4

reg `var'_06_11 land_aval $controls [aw=pop_18_33_00], cluster(statefip)
 local F = (_b[land_aval]/_se[land_aval])^2
 post_param "Fstat" `F'
 est store `var'a4b

}

estout * ///
  using ./output/tableOA17_first_stages`1'.txt,  ///
  stats(Fstat N r2, fmt(%9.3f)) modelwidth(7) varwidth(25) ///
  keep(land_aval) ///
  order(land_aval) ///
  cells(b( fmt(%9.3f)) se(par fmt(%9.3f)) p(par([ ]) fmt(%9.3f)) ) style(tab) replace notype mlabels(, numbers ) 

restore