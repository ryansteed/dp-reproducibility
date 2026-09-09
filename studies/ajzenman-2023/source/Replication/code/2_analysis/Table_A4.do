*------------------------------------------------------------------------------*
* 					Table A4 (Panels A.1-A.3 and B.1-B.3)	 	 		  	   *
*------------------------------------------------------------------------------*

{

* COLUMNAS 2SLS CROSS SECTION
cd "$final"
use enusc_IV, clear 

foreach var in vict_agreg pc_19 pc_20{
	replace `var'=100*`var'
}


local shares share2008_hai share2008_per share2008_col share2008_ven share2008_bol share2008_arg share2008_ecu share2008_eeuu share2008_esp share2008_chi share2008_bra

foreach outcome in vict_agreg pc_19 pc_20{
	qui summ `outcome'
	global IV_mean=r(mean)
	
	qui ivreg2 `outcome' age hombre (deltaimm=deltaimm_instr), robust savefirst
	global IV_bas=e(b)[1,1]
	global IV_se_bas=sqrt(e(V)[1,1])
	global IV_n_bas=e(N)
	global IV_Rsq_bas=e(r2c)
	global F_bas = e(first)[4,1]
	global part_r2_bas = e(first)[3,1]
	
	qui ivreg2 `outcome' (deltaimm=deltaimm_instr), robust savefirst
	global IV_NC=e(b)[1,1]
	global IV_se_NC=sqrt(e(V)[1,1])
	global IV_n_NC=e(N)
	global IV_Rsq_NC=e(r2c)
	global F_NC = e(first)[4,1]
	global part_r2_NC = e(first)[3,1]

	qui ivreg2 `outcome' age hombre (deltaimm_visa=deltaimm_instr_visa), robust savefirst
	global IV_visa=e(b)[1,1]
	global IV_se_visa=sqrt(e(V)[1,1])
	global IV_n_visa=e(N)
	global IV_Rsq_visa=e(r2c)
	global F_visa = e(first)[4,1]
	global part_r2_visa = e(first)[3,1]

	qui ivreg2 `outcome' age hombre (deltaimm_permiso=deltaimm_instr_permiso), robust savefirst
	global IV_perm=e(b)[1,1]
	global IV_se_perm=sqrt(e(V)[1,1])
	global IV_n_perm=e(N)
	global IV_Rsq_perm=e(r2c)
	global F_perm = e(first)[4,1]
	global part_r2_perm = e(first)[3,1]
	
	* Adao
	preserve
	ivreg_ss `outcome', endogenous_var(deltaimm) shiftshare_iv(deltaimm_instr) share_varlist(`shares') control_varlist(age hombre) firststage(1) cluster_var(cod_com) akmtype(0)
	global IV_adao=e(b)[1,1]
	global IV_se_adao= e(b)[1,1]/e(tstat)
	*global IV_se_adao= e(b)[1,1]/(2*invttail(e(df_m),e(p)))
	*global IV_se_adao= e(se)
	global b_firststage = e(b_firststage)
	global se_firststage = e(se_firststage)
	global F_adao = ($b_firststage / $se_firststage)^2
	
	mat `outcome'_iv_base=[J(1,10,.)\ $IV_bas, $IV_se_bas, $IV_NC, $IV_se_NC, $IV_visa, $IV_se_visa, $IV_perm, $IV_se_perm, $IV_adao, $IV_se_adao]
	restore
}

mat iv_base =[J(1,10,.)\vict_agreg_iv_base\pc_19_iv_base\pc_20_iv_base\J(1,10,.)\ $part_r2_bas, ., $part_r2_NC, ., $part_r2_visa, ., $part_r2_perm, ., $part_r2_bas,.\ $IV_n_bas, ., $IV_n_NC, ., $IV_n_visa, ., $IV_n_perm, ., $IV_n_bas, .]


* COLUMNAS 2SLS PANEL

local shares share2008_hai share2008_per share2008_col share2008_ven share2008_bol share2008_arg share2008_ecu share2008_eeuu share2008_esp share2008_chi share2008_bra

foreach outcome in vict_agreg pc_19 pc_20{	
	use IV_panel, clear 
	replace `outcome'=100*`outcome'
	qui summ `outcome'
	global IV_PANEL_mean=r(mean)
	
	tab cod_com, gen(fe_comuna)
	tab year, gen(fe_year)

	qui ivreg2 `outcome' edad ismale fe_year* fe_comuna* (lnrate_stock_imm=imm_instr), robust cluster(cod_com) savefirst partial(fe_year* fe_comuna*)
	global IV_PANEL_bas=e(b)[1,1]
	global IV_PANEL_se_bas=sqrt(e(V)[1,1])
	global IV_PANEL_n_bas=e(N)
	global IV_PANEL_Rsq_bas=e(r2c)
	global F_PANEL_bas = e(first)[4,1]
	global part_r2_PANEL_bas = e(first)[3,1]
	
	qui ivreg2 `outcome' fe_year* fe_comuna* (lnrate_stock_imm=imm_instr), robust cluster(cod_com) savefirst partial(fe_year* fe_comuna*)
	global IV_PANEL_NC=e(b)[1,1]
	global IV_PANEL_se_NC=sqrt(e(V)[1,1])
	global IV_PANEL_n_NC=e(N)
	global IV_PANEL_Rsq_NC=e(r2c)
	global F_PANEL_NC = e(first)[4,1]
	global part_r2_PANEL_NC = e(first)[3,1]
	
	qui ivreg2 `outcome' edad ismale fe_year* fe_comuna* (lnrate_stock_imm_visa=imm_instr_visa), robust cluster(cod_com) savefirst partial(fe_year* fe_comuna*)
	global IV_PANEL_visa=e(b)[1,1]
	global IV_PANEL_se_visa=sqrt(e(V)[1,1])
	global IV_PANEL_n_visa=e(N)
	global IV_PANEL_Rsq_visa=e(r2c)
	global F_PANEL_visa = e(first)[4,1]
	global part_r2_PANEL_visa = e(first)[3,1]

	qui ivreg2 `outcome' edad ismale fe_year* fe_comuna* (lnrate_stock_imm_permiso=imm_instr_permiso), robust cluster(cod_com) savefirst partial(fe_year* fe_comuna*)
	global IV_PANEL_perm=e(b)[1,1]
	global IV_PANEL_se_perm=sqrt(e(V)[1,1])
	global IV_PANEL_n_perm=e(N)
	global IV_PANEL_Rsq_perm=e(r2c)
	global F_PANEL_perm = e(first)[4,1]
	global part_r2_PANEL_perm = e(first)[3,1]
	
	* Adao
	* Denominador
	qui ivreg2 `outcome' edad ismale fe_year1-fe_year9 fe_comuna1-fe_comuna100 (lnrate_stock_imm=imm_instr), robust cluster(cod_com) savefirst partial(fe_year1-fe_year9 fe_comuna1-fe_comuna100)
	gen yvarminusendogvar = `outcome'-e(b)[1,colsof(e(b))]-e(b)[1,1]*lnrate_stock_imm
	*predict residiv, resid 
	qui estimates replay _ivreg2_lnrate_stock_imm
	scalar beta_firststage = abs(r(table) [1,1])

	qui reg imm_instr edad ismale 
	predict error_proyec_instrm, resid
	sum error_proyec_instrm
	gen error_proyec_instrmsq=(error_proyec_instrm-r(mean))^2
	qui sum error_proyec_instrmsq
	scalar sumdots_xi = r(sum)
	scalar denominador=sumdots_xi*beta_firststage

	* Numerador
	gen ones = 1
	matrix vecaccum z_yvarminusendogvar = yvarminusendogvar edad ismale ones, nocons
	mat zT_yvarminusendogvar=z_yvarminusendogvar'
	matrix accum zTz = edad ismale ones, nocons
	matrix inv_zTz = invsym(zTz)
	matrix inv_zTz_z_yvarminusendogvar=inv_zTz*zT_yvarminusendogvar

	gen residiv = yvarminusendogvar-edad*inv_zTz_z_yvarminusendogvar[1,1]-ismale*inv_zTz_z_yvarminusendogvar[2,1]-inv_zTz_z_yvarminusendogvar[rowsof(inv_zTz_z_yvarminusendogvar),1]


	foreach country in "hai" "per" "col" "ven" "bol" "arg" "ecu" "eeuu" "esp" "chi" "bra"{
	gen weightresid`country'=share2008_`country'*residiv
	qui sum weightresid`country'
	scalar sumweightresid`country'=r(sum)
	}

	qui reg error_proyec_instrm share2008_hai share2008_per share2008_col share2008_ven share2008_bol share2008_arg share2008_ecu share2008_eeuu share2008_esp share2008_chi share2008_bra 

	local i = 1
	foreach country in "hai" "per" "col" "ven" "bol" "arg" "ecu" "eeuu" "esp" "chi" "bra"{
	scalar xhat`country' = e(b)[1,`i']
	local i=`i'+1
	}

	local aux = 0
	foreach country in "hai" "per" "col" "ven" "bol" "arg" "ecu" "eeuu" "esp" "chi" "bra"{
	local aux = (sumweightresid`country'^2)*(xhat`country'^2)+`aux'
	}
	scalar numerador = sqrt(`aux')

	* SE coeficiente de var endogena
	global IV_se_PANEL_adao= numerador/denominador
	
	mat `outcome'_iv_panel=[J(1,10,.)\ $IV_PANEL_bas, $IV_PANEL_se_bas, $IV_PANEL_NC, $IV_PANEL_se_NC, $IV_PANEL_visa, $IV_PANEL_se_visa, $IV_PANEL_perm, $IV_PANEL_se_perm, $IV_PANEL_bas, $IV_se_PANEL_adao]
	
}


	
mat iv_panel = [J(1,10,.)\vict_agreg_iv_panel\pc_19_iv_panel\pc_20_iv_panel\J(1,10,.)\ $part_r2_PANEL_bas, ., $part_r2_PANEL_NC, ., $part_r2_PANEL_visa, ., $part_r2_PANEL_perm, ., $part_r2_PANEL_bas, .\ $IV_PANEL_n_bas, ., $IV_PANEL_n_NC, ., $IV_PANEL_n_visa, ., $IV_PANEL_n_perm, ., $IV_PANEL_n_bas, .]

frmttable using "$Tables\Table_A4.tex", tex fr statmat(iv_base) substat(1) ctitles("", "Baseline", "No Controls", "Visas" , "Permits", "Adao" \ "", "", "", "", "", "") rtitles("Panel A: 2SLS in Differences"\""\ "Panel A.1: Victimization"\ ""\ "Log Imm Rate" \ "" \ "Panel A.2: Crime Concerns" \"" \ "Log Imm Rate" \"" \ "Panel A.3: Crime-prev. Behavioral Reactions" \"" \ "Log Imm Rate" \"" \ ""  \ "First Stage Regression"\"Part. R-squared"\""\"N") replace sdec(2) a4
frmttable using "$Tables\Table_A4.tex", tex fr statmat(iv_panel) substat(1) rtitles("Panel B: 2SLS in Levels"\""\ "Panel B.1: Victimization"\ ""\ "Log Imm Rate" \ "" \ "Panel B.2: Crime Concerns" \"" \ "Log Imm Rate" \"" \ "Panel B.3: Crime-prev. Behavioral Reactions" \"" \ "Log Imm Rate" \"" \ ""  \ "First Stage Regression"\"Part. R-squared"\""\"N") append replace sdec(2) a4



}
