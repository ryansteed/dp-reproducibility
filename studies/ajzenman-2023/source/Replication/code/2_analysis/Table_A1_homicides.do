*------------------------------------------------------------------------------*
* 						Tables I and A.1 (Homicides)						   *
*------------------------------------------------------------------------------*
{
cd "$final"
use TableI, clear

** Tabla con Medias y SDs por cuartiles
tabstat growth_imm population2019, by(growth_imm_quartile) stats(mean sd) save

forvalues q = 1/4{
mat q`q' = r(Stat`q')'
}

mat tableI = q1,J(2,1,.),q2,J(2,1,.),q3,J(2,1,.),q4,J(2,1,.)
frmttable using "$Tables\Table_A1_homicides.tex", tex frag replace statmat(tableI) substat(2) ctitles("","Quartile 1","Quartile 2","Quartile 3","Quartile 4") rtitles("Immigrant growth 2017-2008 (in \%)"\""\""\"Population in 2019") sdec(3)

keep cod_com growth_imm_quartile
cd "$conf_final"
save temp.dta, replace


** Vars de Homicidios
use homicides_OLS, replace
keep if year==2008
merge m:1 cod_com using temp
drop _merge

tabstat homicidios1pc, by(growth_imm_quartile) stats(mean sd) save
forvalues q = 1/4{
mat q`q' = r(Stat`q')'
}

erase temp.dta

mat tableI_enusc = q1,J(1,1,.),q2,J(1,1,.),q3,J(1,1,.),q4,J(1,1,.)
frmttable using "$Tables\Table_A1_homicides.tex", tex frag append replace statmat(tableI_enusc) substat(2) ctitles("","Quartile 1","Quartile 2","Quartile 3","Quartile 4") rtitles("Homicide Rate") sdec(3)

}
/*
{
cd "$final"
use TableI, clear

** Tabla con Medias y SDs por cuartiles
tabstat growth_imm population2019, by(growth_imm_quartile) stats(mean sd) save

forvalues q = 1/4{
mat q`q' = r(Stat`q')'
}

mat tableI = q1,J(2,1,.),q2,J(2,1,.),q3,J(2,1,.),q4,J(2,1,.)
frmttable using "$Tables\Table_A1_homicides.tex", tex frag replace statmat(tableI) substat(2) ctitles("","Quartile 1","Quartile 2","Quartile 3","Quartile 4") rtitles("Immigrant growth 2017-2008 (in \%)"\""\""\"Population in 2019") sdec(3)

keep cod_com growth_imm_quartile
cd "$conf_final"
save temp.dta, replace


** Vars de Homicidios
use homicides_OLS, replace
keep if year==2017
merge m:1 cod_com using temp
drop _merge

tabstat homicidios1pc, by(growth_imm_quartile) stats(mean sd) save
forvalues q = 1/4{
mat q`q' = r(Stat`q')'
}

erase temp.dta

mat tableI_enusc = q1,J(1,1,.),q2,J(1,1,.),q3,J(1,1,.),q4,J(1,1,.)
frmttable using "$Tables\Table_A1_homicides.tex", tex frag append replace statmat(tableI_enusc) substat(2) ctitles("","Quartile 1","Quartile 2","Quartile 3","Quartile 4") rtitles("Homicide Rate") sdec(3)

}
*/
