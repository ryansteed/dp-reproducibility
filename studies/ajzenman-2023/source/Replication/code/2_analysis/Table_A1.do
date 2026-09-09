*------------------------------------------------------------------------------*
* 							Tables I and A.1								   *
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
frmttable using "$Tables\Table_A1.tex", tex frag replace statmat(tableI) substat(2) ctitles("","Quartile 1","Quartile 2","Quartile 3","Quartile 4") rtitles("Immigrant growth 2017-2008 (in \%)"\""\""\"Population in 2019") sdec(3)

keep cod_com growth_imm_quartile
save temp.dta, replace

** Vars de ENUSC
use enusc_OLS, replace
keep if year==2008
merge m:1 cod_com using temp
drop _merge


** Completo Tabla con Medias y SDs por cuartiles para vars de ENUSC
gen isfemale=1-ismale
tabstat edad isfemale del_problema3 del_afecta3 del_calvida3 del_inseg5 del_vict del_tend_barrio del_tend_com del_tend_pais Index_Vivienda Index_Vecinos del_arma vict_roboviolent vict_robosorpr vict_roboviv vict_hurto vict_lesiones vict_robovehi, by(growth_imm_quartile) stats(mean sd) save

forvalues q = 1/4{
mat q`q' = r(Stat`q')'
}

erase temp.dta

mat tableI_enusc = q1,J(19,1,.),q2,J(19,1,.),q3,J(19,1,.),q4,J(19,1,.)
frmttable using "$Tables\Table_A1.tex", tex frag append replace statmat(tableI_enusc) substat(2) ctitles("","Quartile 1","Quartile 2","Quartile 3","Quartile 4") rtitles("Age"\""\""\"Female"\ ""\""\"Crime as a 1st or 2nd Concern "\""\""\ "Crime as Impacting Personal Life "\""\""\"Crime Affecting Quality of Life"\""\""\"Feeling Unsafe"\""\""\"Will be a Victim"\""\""\"Crime rising: Country"\""\""\"Crime rising: Municipality"\""\""\"Crime rising: Neighborhood/Village"\""\""\"Investment in Home Security"\""\""\"Neighbors' Security System"\""\""\"Owns a Weapon"\""\""\"Robbery"\""\""\"Larceny"\""\""\"Burglary"\""\""\"Theft"\""\""\"Assault"\""\""\"Motor Vehicle Theft") sdec(3)

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
frmttable using "$Tables\Table_A1.tex", tex frag replace statmat(tableI) substat(2) ctitles("","Quartile 1","Quartile 2","Quartile 3","Quartile 4") rtitles("Immigrant growth 2017-2008 (in \%)"\""\""\"Population in 2019") sdec(3)

keep cod_com growth_imm_quartile
save temp.dta, replace

** Vars de ENUSC
use enusc_OLS, replace
keep if year==2017
merge m:1 cod_com using temp
drop _merge


** Completo Tabla con Medias y SDs por cuartiles para vars de ENUSC
gen isfemale=1-ismale
tabstat edad isfemale del_problema3 del_afecta3 del_calvida3 del_inseg5 del_vict del_tend_barrio del_tend_com del_tend_pais Index_Vivienda Index_Vecinos del_arma vict_roboviolent vict_robosorpr vict_roboviv vict_hurto vict_lesiones vict_robovehi, by(growth_imm_quartile) stats(mean sd) save

forvalues q = 1/4{
mat q`q' = r(Stat`q')'
}

erase temp.dta

mat tableI_enusc = q1,J(19,1,.),q2,J(19,1,.),q3,J(19,1,.),q4,J(19,1,.)
frmttable using "$Tables\Table_A1.tex", tex frag append replace statmat(tableI_enusc) substat(2) ctitles("","Quartile 1","Quartile 2","Quartile 3","Quartile 4") rtitles("Age"\""\""\"Female"\ ""\""\"Crime as a 1st or 2nd Concern "\""\""\ "Crime as Impacting Personal Life "\""\""\"Crime Affecting Quality of Life"\""\""\"Feeling Unsafe"\""\""\"Will be a Victim"\""\""\"Crime rising: Country"\""\""\"Crime rising: Municipality"\""\""\"Crime rising: Neighborhood/Village"\""\""\"Investment in Home Security"\""\""\"Neighbors' Security System"\""\""\"Owns a Weapon"\""\""\"Robbery"\""\""\"Larceny"\""\""\"Burglary"\""\""\"Theft"\""\""\"Assault"\""\""\"Motor Vehicle Theft") sdec(3)

}
*/
