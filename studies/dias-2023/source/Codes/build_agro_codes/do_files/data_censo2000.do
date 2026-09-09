********************************************************************************
* Municipalities and codes (from Pesquisa Agricola Municipal)

foreach i in analfabetos15anos2000 poprural2000 rendapc2000 share_pobres2000 Theil2000 agua_encanada2000 latitude longitude area {


clear
import excel using "$pathfiles_data/Originais/Ipeadata originais censo 2000/ipeadata_`i'.xlsx"

rename A codmun7
rename B `i'
drop if _n==1
destring, replace

save "$pathfiles_data/Originais/Ipeadata originais censo 2000/temp`i'.dta", replace
}

foreach i in analfabetos15anos2000 poprural2000 rendapc2000 share_pobres2000 Theil2000 agua_encanada2000 latitude longitude area {
merge 1:1 codmun7 using "$pathfiles_data/Originais/Ipeadata originais censo 2000/temp`i'.dta"
drop _m
}

save "$pathfiles_data/Workfiles/data_censo2000.dta", replace
clear

foreach i in analfabetos15anos2000 poprural2000 rendapc2000 share_pobres2000 Theil2000 agua_encanada2000 latitude longitude area {
erase "$pathfiles_data/Originais/Ipeadata originais censo 2000/temp`i'.dta"
}

