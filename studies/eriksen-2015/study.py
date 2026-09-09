from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Eriksen(Study):
    id = 'eriksen-2015'

    def data_paths(self) -> dict:
        return {
            "AEJEP_Regression_Data_6-24-14": os.path.join(
                self.path(), "source/data", "AEJEP_Regression_Data_6-24-14.dta"
            )
            # ...
        }
    
    def vars_to_noise(self) -> list:
        # list all personal vars used in the regression
        return [
            "ltotpop",  
            "linc"
        ]
    
    def _pre_processing(self, data):
        df = data["AEJEP_Regression_Data_6-24-14"]

        df["pop"] = np.exp(df["ltotpop"])
        df["inc_total"] = np.exp(df["linc"]) * df["pop"]

        data["AEJEP_Regression_Data_6-24-14"] = df
        return data
    
    def _post_processing(self, noised_data):
        df = noised_data["AEJEP_Regression_Data_6-24-14"]

        df["ltotpop"] = np.log(df["pop"])
        df["totpop"] = np.exp(df["ltotpop"]) / 1000

        df["linc"] = np.log(df["inc_total"] / df["pop"])
        df["inc"] = np.exp(df["linc"]) / 1000

        noised_data["AEJEP_Regression_Data_6-24-14"] = df
        return noised_data

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `AEJ_Regression_Program-6-24-14.do`: ###
        # use AEJEP_Regression_Data_6-24-14, clear;
        # global depvar   lrent_ut;                          /*log of reported cash rent plus utilities from AHS*/

        # global vouchers lvouch;                            /*Log of Housing Vouchers at the MSA Level from the Federal Register*/

        # global cntrls   linc   ltotpop lvacancy              
        #                 evrod  drywash cracks   ifsew;  /*Log of MSA annual income, population, and vacancy rates from Census Log of Unit-specific Attributes from AHS*/
        # ...
        ## TABLE 4
        # eststo: xi: xtreg $depvar $vouchers $cntrls  i.year 
        # , fe i(control) cluster(smsa) nonest;
        
        # eststo: xi: xtreg $depvar $vouchers $cntrls  i.year 
        #     if fmrratio < 1.2 
        # , fe i(control) cluster(smsa) nonest;
        
        # eststo: xi: xtreg $depvar $vouchers $cntrls  i.year 
        #     if fmrratio >= 1.2 
        # , fe i(control) cluster(smsa) nonest;

        ## TABLE 5

        # gen fmrratio_low  = fmrratio <  .8;
        # gen fmrratio_mid  = fmrratio >= .8 & fmrratio < 1.2;
        # gen fmrratio_high = fmrratio >= 1.2;

        # gen INT_fmrlow = lvouch  * fmrratio_low;
        # gen INT_fmrmid = lvouch * fmrratio_mid;

        # gen fmrratio_bins     = fmrratio_low;
        # replace fmrratio_bins = 2 if fmrratio_mid == 1;

        # eststo: xi: xtreg $depvar $vouchers $cntrls  i.year*lfmrratio 
        #     if fmrratio < .8  
        # , fe i(control) cluster(smsa) nonest;

        # eststo: xi: xtreg $depvar $vouchers $cntrls  i.year*lfmrratio 
        #     if fmrratio >= .8 & fmrratio < 1.2 
        # , fe i(control) cluster(smsa) nonest;

        # eststo: xi: xtreg $depvar $vouchers INT_fmrlow $cntrls  i.year*i.fmrratio_bins 
        #     if fmrratio < 1.2 
        # , fe i(control) cluster(smsa) nonest;

        ## TABLE 7
        # gen lsaiz = log(saiz);

        # gen saiz_g1 = saiz >= 1 & saiz ~= .;
        # gen saiz_l1 = saiz  < 1 & saiz ~= .;

        # gen INT_saizg1 = $vouchers * saiz_g1 if saiz ~= .;
        # gen INT_saizl1 = $vouchers * saiz_l1 if saiz ~= .;


        # gen INT_saizl1_fmrlow = INT_fmrlow*INT_saizl1;
        # gen INT_saizl1_fmrmid = INT_fmrmid*INT_saizl1;
        # gen INT_saizg1_fmrlow = INT_fmrlow*INT_saizg1;
        # gen INT_saizg1_fmrmid = INT_fmrmid*INT_saizg1;

        # local cluster smsa;

        # eststo: xi: xtreg $depvar $vouchers  $cntrls  i.year*lsaiz 
        #     if  saiz ~= . & fmrratio < 1.2 
        # , fe i(control) cluster(smsa) nonest;

        # eststo: xi: xtreg $depvar $vouchers INT_saizg1 $cntrls i.year*lsaiz 
        #     if  saiz ~= . & fmrratio < 1.2 
        # , fe i(control) cluster(smsa) nonest;

        # lincom lvouch + INT_saizg1;

        # eststo: xi: xtreg $depvar $vouchers INT_saizg1 INT_fmrlow INT_saizg1_fmrlow $cntrls i.year*lsaiz i.year*fmrratio_bins 
        #     if  saiz ~= . & fmrratio < 1.2
        # , fe i(control) cluster(smsa) nonest;
        ###

        sensitivities = {
            ### ltotpop: Log of MSA population from Census
            # ltotpop = log(totpop * 1000) = log(pop / 1000)
            # (ltotpop is in 1s, totpop is in 1000s)
            # reconstructing pop = exp(ltotpop)
            "pop": lambda msa: 1,

            ### linc: Log of MSA per capita annual income from Census
            # linc = log(inc * 1000) = log(inc_total / totpop)
            # (linc is in 1s, inc is in 1000s)
            # reconstructing inc_total = exp(linc)
            # NOTE: assuming income clipped at 500k
            "inc_total": lambda msa: 500000
            # pop already noised

            ### [not personal]lrent_ut: log of reported cash rent plus utilities from AHS
            ### [not personal]lvouch: Log of Housing Vouchers at the MSA Level from the Federal Register
            ### [not personal]lvacancy: Log of vacancy rates from Census            
            ### [not personal]evrod: Evidence of Rodents
            ### [not personal]drywash: Presence of washer or dryer
            ### [not personal]cracks: Visible Cracks in Unit, Log of Unit-specific Attributes from AHS
            ### [not personal] ifsew: Has the house ever had a sewage break?
            ### [not personal] year
            ### [not personal]fmrratio: The variable "fmrratio" is the unit-specific housing rent in 1997 divided by the MSA-Specific Fair Market Rent
            ### [not personal]lfmrratio: the variable "lfmrratio" is the natural log of fmrratio.
            ### [not personal]saiz: The variable "saiz" is housing supply elasticity as estimated by Saiz (2011)
            ### [not personal]lsaiz: the natural log of saiz
            ### [not personal] INT_fmrlow:
            # gen fmrratio_low  = fmrratio <  .8;
            # gen INT_fmrlow = lvouch  * fmrratio_low;
            ### [not personal] fmrratio_bins:
            # gen fmrratio_bins     = fmrratio_low;
            # replace fmrratio_bins = 2 if fmrratio_mid == 1;
            ### [not personal] INT_saizg1:
            # gen saiz_g1 = saiz >= 1 & saiz ~= .;
            # gen INT_saizg1 = $vouchers * saiz_g1 if saiz ~= .;
            ### [not personal] INT_saizg1_fmrlow:
            # gen INT_saizg1_fmrlow = INT_fmrlow*INT_saizg1;
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table4.csv")
        results.append(Result.from_esttab(
            id="voucher-rent",
            table=table,
            row="lvouch",
            col="est1",
            expected_range=(0, 0)
        ))
        table = self._load_esttab(f"{self.path()}/results/table5.csv")
        results.append(Result.from_esttab(
            id="voucher-cheap",
            table=table,
            row="lvouch",
            col="est1",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="voucher-expensive",
            table=table,
            row="lvouch",
            col="est2",
            expected_range=(0, None)
        ))
        results.append(Result.from_esttab(
            id="voucher-fmr",
            table=table,
            row="INT_fmrlow",
            col="est3",
            expected_range=(None, 0)
        ))
        table = self._load_esttab(f"{self.path()}/results/table7.csv")
        results.append(Result.from_esttab(
            id="elasticity-effect",
            table=table,
            row="INT_saizg1",
            col="est3",
            expected_range=(None, 0)
        ))
        return results