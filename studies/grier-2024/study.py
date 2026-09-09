from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Grier(Study):
    id = 'grier-2024'

    def data_paths(self) -> dict:
        return {
            "Replication_Data": os.path.join(
                self.path(), "source", "Replication_Data.dta"
            ),
            # "final": os.path.join(
            #     self.path(), "source", "final.dta"
            # ), # created by us, for monitoring only
            # ...
        }
    
    def vars_to_noise(self) -> dict:
        # list all personal vars used in the regression
        return {
            "post_replication": [
                "pcyminus5",
                # "dflfper",
                "dfprimary" 
            ]
        }
    
    def _pre_processing(self, data):
        df = data["Replication_Data"]
        df["count_prim"] = df["Primary_Complete"] / 100 * df["pop"] / 2 * 100000
        return data
    
    def _post_processing(self, noised_data):
        df = noised_data["Replication_Data"]
        df["Primary_Complete"] = df["count_prim"] / df["pop"] * 2 * 100 / 100000
        return noised_data

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `Gender_Replication.do`: ###
        # use "Replication_Data.dta", replace
        # ...
        # xtset id year
        # ...
        # gen dfprimary=f5.Primary_Complete-Primary_Complete
        # gen dflfper=f5.Labor_Force_Percent-Labor_Force_Percent
        # /*Generate Leads and Lags for Covariates*/
        # gen pcy=rgdpe/pop
        # gen pcyminus5=l5.pcy
        # gen hcminus5=l5.hc
        # gen csh_x5=l5.csh_x
        # gen csh_g5=l5.csh_g
        # gen inf5=l5.Inflation
        # gen EFW5=l5.EFW
        # gen lvdemoc=l5.vdemoc
        # ...
        #--- reform-lf
        # eststo: bootstrap r(att), r(250) : psmatch2 jump hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, /// 
        # out(dflfper) common ate logit  n(1)
        # ...
        #--- reform-schooling
        # eststo schooling: bootstrap r(att), r(250) : psmatch2 jump hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc ///
        # , out(dfprimary) kernel k(normal) common ate
        sensitivities = {
            ### pcyminus5 : Real per-capita income
            #> gen pcy=rgdpe/pop
            #> gen pcyminus5=l5.pcy
            # pop seems to be in 100,000s
            "pop": lambda country: 1/100000,
            # [not personal] rgdpe: Real GDP]
            
            ### dflfper: change in % of labor force that is female
            #> gen dflfper=f5.Labor_Force_Percent-Labor_Force_Percent
            # Labor_Force_Percent: % of the total labor force that is female
            # Labor_Force_Part: % females 15-24 in the labor force
            # Labor_Force_Part_all = % females 15 or older in the labor force
            # NOTE: pop female, labor force size not known; cannot noise

            ### dfprimary : change in % females that completed primary education
            # Note: gen dfprimary=f5.Primary_Complete-Primary_Complete
            # Primary_Complete: % females that finished primary education
            # Primary_Complete = count_prim / pop * 2
            # NOTE: creating inter var count_prim = Primary_Complete * pop / 2
            # NOTE: assuming female is 50% of population
            # pop already noised
            "count_prim": lambda country: 1

            ### [not personal] lvdemoc: Democracy Score
            ### [not personal]  csh_g5: Government Share of GDP
            ### [not personal]  inf5: Inflation Rate
            ### [not personal] EFW5: Economic Freedom Score (EFW)
            ### [not personal] jump: jumps in economic freedom on women’s labor force participation
            #> gen jump=0
            #> replace jump=1 if EFWchange > = 1 & nextchange > =  -.20 & nextchange != .
            #> replace jump=0 if prevchange > = 1 & prevchange != .
            #> replace jump = . if missing(EFWchange)
            ## [not personal] EFWchange 
            #> gen EFWchange= EFW-EFW5 
            # [not personal] EFW: economic freedom measure
            ### [not personal] hcminus5: Human Capital investment?
            #> gen hcminus5=l5.hc

            ### [not personal] csh_x5: Export Share of GDP
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table_lf = self._load_esttab(f"{self.path()}/results/table_lf.csv")
        results.append(Result.from_esttab(
            id="reform-lf",
            table=table_lf,
            row="_bs_1",
            col="est1",
            expected_range=(0, None)
        ))
        table_sch = self._load_esttab(f"{self.path()}/results/table_schooling.csv")
        results.append(Result.from_esttab(
            id="reform-schooling",
            table=table_sch,
            row="_bs_1",
            col="schooling",
            expected_range=(0, None)
        ))
        return results