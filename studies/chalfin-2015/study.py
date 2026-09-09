from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Chalfin(Study):
    id = 'chalfin-2015'

    def data_paths(self) -> dict:
        return {
            "chalfin_data": os.path.join(
                self.path(), "source", "data","chalfin_data.dta"
            )
            # ...
        }
    
    def _pre_processing(self, data):
        df = data["chalfin_data"]

        # deconstruct per capita vars
        self._pc_vars = [
            "black",
            "educ1",
            "educ2",
            "educ3",
            "educ4",
            "age0_14",
            "age15_24",
            "age25_39",
            "age40_54",
            "age55",
            "employed",
            "ushisp",
            "fbnonmex",
            "usmex",
            "mexfba"
        ]
        for v in self._pc_vars:
            df[f"n{v}"] = df[v] * df["population"]

        data["chalfin_data"] = df
        return data
    
    def _post_processing(self, noised_data):
        df = noised_data["chalfin_data"]

        # reconstruct per capita vars
        for v in self._pc_vars:
            df[v] = df[f"n{v}"] / df["population"]
        
        # reconstruct crime vars
        for v in [
            "rape",
            "larceny",
            "motor"
        ]:
            df[f"logpc_{v}"] = np.where(
                df[f"logpc_{v}"].isna(),
                np.nan,
                np.log(df[v] / df["population"] * 100000)
            )
        
        # reconstruct d vars
        for v in self._pc_vars:
            df[f"d{v}"] = df.groupby("FMSA")[v].diff() * (
                100 if v in ["fbnonmex", "ushisp", "usmex"]
                else 1
            )
            # fix small floating point errors for validation:
            for fperr, corrected in {
                -0.0003445: -0.00034449,
                -3.6050379e-04: -3.6048889e-04,
                4.7634542e-04: 4.7633052e-04,
                -4.4113398e-04: -4.4114888e-04,
                -3.0711293e-05: -3.0696392e-05,
                -0.00372744: -0.00372738,
                0.00086135: 0.00086129,
                -0.00265104: -0.0026511,
                -0.00062811: -0.00062817
            }.items():
                df.loc[np.isclose(df[f"d{v}"], fperr), f"d{v}"] = np.float32(corrected)
        
        df["dmexfb_alt"] = df["dmexfba"] * 100

        noised_data["chalfin_data"] = df
        return noised_data
    
    def vars_to_noise(self) -> list:
        return [
            "dmexfb_alt",
            # "dins",
            "deduc1",
            "deduc2",
            "deduc3",
            "deduc4",
            "dblack",
            "dage0_14",
            "dage15_24",
            "dage25_39",
            "dage40_54",
            "dage55",
            "demployed",
            # "dusbirths",
            "dfbnonmex",
            "dushisp",
            # "dlogpc_rape",
            # "dlogpc_larceny",
            # "dlogpc_motor",
            # "dmexfbk",
            # "popweight"
        ]
    
    def other_vars(self):
        return [
            "dins",
            "dusbirths",
            "dlogpc_rape",
            "dlogpc_larceny",
            "dlogpc_motor",
            "dmexfbk",
            "region"
        ]
    
    def time_index(self):
        return "year"
    
    def subset_index(self):
        return "FMSA"
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `chalfin_code.do`: ###
        # use "`comp'/chalfin_data.dta", clear
        # ...
        # local w popweight // analytic weight
        # local covs deduc* dblack dage* demployed dusbirths  // covariates
        # local endog dmexfb_alt
        # local groups dfbnonmex dushisp dmexfbk // groups
        # local crimes murder rape robbery assault burglary larceny motor //crimes
        # local other dfbnonmex dushisp
        # ...
        # foreach i of varlist `crimes' {
        #     eststo: ivreg2 dlogpc_`i' (`endog' = dins) `covs' `other' grp_* ///
        #     [aweight=`w'], `se'
        # }
        ###
        sensitivities = {
            ### dins: number of Mexican births predicted to end up in MSA assuming entire cohort migrates, deflated by population
            # NOTE: too complex to reconstruct, not enough info

            ### per-capita differenced vars
            # NOTE: reconstructing d* = by FMSA: diff(*)
            # * = n* / population
            # using population, not poptotal; poptotal appears to come from crime dataset, not IPUMS
            # NOTE: created var n* = * * population
            "population": lambda msayear: 1,

            ## deduc*: change in education level *
            "neduc1": lambda msayear: 1,
            "neduc2": lambda msayear: 1,
            "neduc3": lambda msayear: 1,
            "neduc4": lambda msayear: 1,

            ### dblack: change in % black?
            "nblack": lambda msayear: 1,

            ### dage*: change in % age *?
            "nage0_14": lambda msayear: 1,
            "nage15_24": lambda msayear: 1,
            "nage25_39": lambda msayear: 1,
            "nage40_54": lambda msayear: 1,
            "nage55": lambda msayear: 1,

            ### demployed: change in % employed?
            "nemployed": lambda msayear: 1,

            ### dushisp: change in % US born hispanic?
            "nushisp": lambda msayear: 1,

            ### dfbnonmex: change in non-mexican foreign births?
            "nfbnonmex": lambda msayear: 1,

            ### dmexfb_alt: change in mexican foreign births?
            # NOTE: reconstructed dmexfb_alt = dmexfba * 100
            # NOTE: reconstructing dmexfba = by FMSA: diff(mexfba)
            # NOTE: created var nmexfba = mexfba * population
            "nmexfba": lambda msayear: 1,

            ### dusbirths: change in us births to mexican-born parents?
            # NOTE: can't figure out how to reconstruct, not enough info

            ### [not personal] grp_*: group dummies

            #-- mexican-rape
            ### dlogpc_rape: change in log per capita rape
            # reconstructed logpc_rape successfully, but
            # NOTE: can't figure out how to reconstruct, not enough info
            #--
            #-- mexican-larceny
            ### dlogpc_larceny: change in log per capita larceny
            # NOTE: can't figure out how to reconstruct, not enough info
            #--
            #-- mexican-motor
            ### dlogpc_motor: change in log per capita motor vehicle theft
            # NOTE: can't figure out how to reconstruct, not enough info
            #--
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="mexican-rape",
            table=table,
            row="dmexfb_alt",
            col="est2",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="mexican-larceny",
            table=table,
            row="dmexfb_alt",
            col="est6",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="mexican-motor",
            table=table,
            row="dmexfb_alt",
            col="est7",
            expected_range=(None, 0)
        ))
        return results