*------------------------------------------------------------------------------*
* 									Figure A5				 	 		  	   *
*------------------------------------------------------------------------------*
{

cd "$conf_final"
use pretrendsfinalbase_homicides, clear
keep if year==2017 

*controles usados: age, hombre
*weights: fact_hog por comuna
matrix B=J(11,4,.)
matrix colnames B= noWnoC noWsiC siWnoC siWsiC
matrix rownames B= HAI PER COL VEN BOL ARG ECU EEUU ESP CHI BRA
bartik_weight, weightstub(delta_hai delta_per delta_col delta_ven delta_bol delta_arg delta_ecu delta_eeuu delta_esp delta_chi delta_bra ) z(share_hai share_per share_col share_ven share_bol share_arg share_ecu share_eeuu share_esp share_chi share_bra) x(deltaimm) y(crime_rising)  
mat B[1,1]=r(alpha)
bartik_weight, weightstub(delta_hai delta_per delta_col delta_ven delta_bol delta_arg delta_ecu delta_eeuu delta_esp delta_chi delta_bra ) z(share_hai share_per share_col share_ven share_bol share_arg share_ecu share_eeuu share_esp share_chi share_bra ) x(deltaimm) y(crime_rising) controls(age hombre) 
mat B[1,2]=r(alpha)
bartik_weight, weightstub(delta_hai delta_per delta_col delta_ven delta_bol delta_arg delta_ecu delta_eeuu delta_esp delta_chi delta_bra ) z(share_hai share_per share_col share_ven share_bol share_arg share_ecu share_eeuu share_esp share_chi share_bra) x(deltaimm) y(crime_rising)  weight_var(fact_hog)
mat B[1,3]=r(alpha)
bartik_weight, weightstub(delta_hai delta_per delta_col delta_ven delta_bol delta_arg delta_ecu delta_eeuu delta_esp delta_chi delta_bra ) z(share_hai share_per share_col share_ven share_bol share_arg share_ecu share_eeuu share_esp share_chi share_bra ) x(deltaimm) y(crime_rising) controls(age hombre) weight_var(fact_hog)
mat B[1,4]=r(alpha)

mat list B

*La exporto a mano
cd "$conf_final"
use pretrendsfinalbase_homicides, clear
drop if  year==2003|year==2017
sort cod_com year
bys cod_com: egen pop=max(population)
set graphics off

local sharesnW c.share_per c.share_bol c.share_chi c.share_ecu c.share_bra /*SOLO TIENE TOP 5. El orden es el mismo sin importar si lo calculo con o sin controles. Con weights cambiaria un poco */
local shares c.share_per c.share_bol c.share_chi c.share_ecu c.share_bra c.share_hai c.share_esp c.share_col c.share_ven c.share_arg c.share_eeuu
local controls c.age c.hombre



label var homicidios1pc "Homicide Rate"
gen years=(year==2005)+2*(year==2006)+3*(year==2007)+4*(year==2008)
sort cod_com year
bys cod_com: replace age=age[_n+1] if year==2007
sort cod_com year
bys cod_com: replace hombre=hombre[_n+1] if year==2007
matrix A = (1,.,.,.\2,.,.,.\3,.,.,.\4,.,.,.)
matrix B = (1,.,.,.\2,.,.,.\3,.,.,.\4,.,.,.)
matrix C = (1,.,.,.\2,.,.,.\3,.,.,.\4,.,.,.)
reg homicidios1pc i.years##(`controls') i.years##(`shares') i.cod_com, r cluster(cod_com)

test (_b[2.years#c.share_per]=0) (_b[3.years#c.share_per]=0) (_b[4.years#c.share_per]=0)
local Fb : display %6.2f r(F)
local pvalb : display %6.3f r(p)
matrix table=table\ `Fb',`pvalb'

*Grafico de peru
forvalues y = 1(1)4 {
	matrix B[`y',2] = _b[`y'.years#c.share_per]*100
	matrix B[`y',3] = _b[`y'.years#c.share_per]*100 - 1.96*_se[`y'.years#c.share_per]*100
	matrix B[`y',4] = _b[`y'.years#c.share_per]*100 + 1.96*_se[`y'.years#c.share_per]*100
}
mat list B

svmat B
cap drop time coef_es ci1 ci2
rename B1 time
rename B2 coef_es
rename B3 ci1
rename B4 ci2
*Los labels de las variables se crean cuando se genera la base en el dofile "Pretrends"
qui twoway rcap ci1 ci2 time, legend(off) || scatter coef_es time, yline(0, lstyle(foreground)) xtitle("") ytitle("", size(vlarge))  graphregion(color(white)) ylab(#3 ,nogrid labsize(huge)) legend(off)  xlab(1 "2005" 2 "2006" 3 "2007" 4 "2008", labsize(huge) angle(60)) title(`: variable label homicidios1pc', size(vhuge)) 
//note( ///"F statistic = `Fb'" ///"P-value = `pvalb'", size(large))
graph export "${Graphs}/homicidios1pc_PERU.pdf" , as(pdf) replace

*Grafico prom ponderado de los top5
test (2.173*_b[2.years#c.share_per]+0.484*_b[2.years#c.share_bol]+0.092*_b[2.years#c.share_ecu]+0.087*_b[2.years#c.share_chi]+0.009*_b[2.years#c.share_bra]=0) (2.173*_b[3.years#c.share_per]+0.484*_b[3.years#c.share_bol]+0.092*_b[3.years#c.share_ecu]+0.087*_b[3.years#c.share_chi]+0.009*_b[3.years#c.share_bra]=0) (2.173*_b[4.years#c.share_per]+0.484*_b[4.years#c.share_bol]+0.092*_b[4.years#c.share_ecu]+0.087*_b[4.years#c.share_chi]+0.009*_b[4.years#c.share_bra]=0) 
local Fa : display %6.2f r(F)
local pvala : display %6.3f r(p)
matrix table=table\ `Fa',`pvala'

forvalues y = 1(1)4 {
//		POR AHORA ESTO LO  HAGO A MANO, DESPUES LO SIGO Y SI SE PUEDE LO AUTOMATIZO PARA QUE NO HAYA QUE METER LOS SHARES A MANO
	lincom 2.173*`y'.years#c.share_per + 0.484*`y'.years#c.share_bol + 0.092*`y'.years#c.share_ecu + 0.087*`y'.years#c.share_chi + 0.009*`y'.years#c.share_bra
	matrix A[`y',2] = r(estimate)*100
	matrix A[`y',3] = r(lb)*100
	matrix A[`y',4] =r(ub)*100
}
mat list A
svmat A
cap drop time coef_es ci1 ci2
rename A1 time
rename A2 coef_es
rename A3 ci1
rename A4 ci2
qui twoway rcap ci1 ci2 time, legend(off) || scatter coef_es time, yline(0, lstyle(foreground)) xtitle("") ytitle("", size(vlarge))  graphregion(color(white)) ylab(#3 ,nogrid labsize(huge)) legend(off)  xlab(1 "2005" 2 "2006" 3 "2007" 4 "2008", labsize(huge) angle(60)) title(`: variable label homicidios1pc', size(vhuge))  
//note( ///"F statistic = `Fa'" ///"P-value = `pvala'", size(large))
graph export "${Graphs}/homicidios1pc_top5.png" , as(png) replace

*Grafico prom ponderado de TODOS
test (2.173*_b[2.years#c.share_per]+0.484*_b[2.years#c.share_bol]+0.092*_b[2.years#c.share_ecu]+0.087*_b[2.years#c.share_chi]+0.009*_b[2.years#c.share_bra]+0.006*_b[2.years#c.share_hai]-0.082*_b[2.years#c.share_col]-1.582*_b[2.years#c.share_arg]-0.189*_b[2.years#c.share_eeuu]-0.049*_b[2.years#c.share_esp]=0) (2.173*_b[3.years#c.share_per]+0.484*_b[3.years#c.share_bol]+0.092*_b[3.years#c.share_ecu]+0.087*_b[3.years#c.share_chi]+0.009*_b[3.years#c.share_bra]+0.006*_b[3.years#c.share_hai]-0.082*_b[3.years#c.share_col]-1.582*_b[3.years#c.share_arg]-0.189*_b[3.years#c.share_eeuu]-0.049*_b[3.years#c.share_esp]=0) (2.173*_b[4.years#c.share_per]+0.484*_b[4.years#c.share_bol]+0.092*_b[4.years#c.share_ecu]+0.087*_b[4.years#c.share_chi]+0.009*_b[4.years#c.share_bra]+0.006*_b[4.years#c.share_hai]-0.082*_b[4.years#c.share_col]-1.582*_b[4.years#c.share_arg]-0.189*_b[4.years#c.share_eeuu]-0.049*_b[4.years#c.share_esp]=0)
local Fc : display %6.2f r(F)
local pvalc : display %6.3f r(p)
matrix table=table\ `Fc',`pvalc'

forvalues y = 1(1)4 {
	lincom 2.173*`y'.years#c.share_per + 0.484*`y'.years#c.share_bol + 0.092*`y'.years#c.share_ecu + 0.087*`y'.years#c.share_chi + 0.009*`y'.years#c.share_bra + 0.006*`y'.years#c.share_hai - 0.082*`y'.years#c.share_col - 1.582*`y'.years#c.share_arg - 0.189*`y'.years#c.share_eeuu - 0.049*`y'.years#c.share_esp
	matrix C[`y',2] = r(estimate)*100
	matrix C[`y',3] = r(lb)*100
	matrix C[`y',4] =r(ub)*100
}
mat list C
svmat C
cap drop time coef_es ci1 ci2
rename C1 time
rename C2 coef_es
rename C3 ci1
rename C4 ci2
qui twoway rcap ci1 ci2 time, legend(off) || scatter coef_es time, yline(0, lstyle(foreground)) xtitle("") ytitle("", size(vlarge))  graphregion(color(white)) ylab(#3 ,nogrid labsize(huge)) legend(off)  xlab(1 "2005" 2 "2006" 3 "2007" 4 "2008", labsize(huge) angle(60)) title(`: variable label homicidios1pc', size(vhuge)) 
//note( ///"F statistic = `Fc'" ///"P-value = `pvalc'", size(large))
graph export "${Graphs}/homicidios1pc_all.pdf" , as(pdf) replace



}
