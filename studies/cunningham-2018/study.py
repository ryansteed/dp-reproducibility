from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Cunningham(Study):
    id = 'cunningham-2018'

    def data_paths(self) -> dict:
        return {
            "aeapp_protests_table_1": os.path.join(
                self.path(), "source/data", "aeapp_protests_table_1.dta"
            )
            # ...
        }
    
    def vars_to_noise(self) -> list:
        # list all personal vars used in the regression
        return [
            "deaths_nw_police",
            "_popwgt_nw",
            "x_blacktrend",
            "x_dentrend",
            # "x_uetrend",
            # "x_pubtranstrend",
            # "x_povertytrend",
            # "x_whiteinctrend",
            # "x_blackinctrend",
            # "x_pubasstrend",
            # "x_owntrend"
            # ...
        ]
    
    def _pre_processing(self, data):
        df = data["aeapp_protests_table_1"]
        df["trend"] = np.where(
            df["_popwgt_nw"] == 0,
            0,
            df["x_blacktrend"] * df["_popwgt"] / df["_popwgt_nw"]
        )
        df["mileage_per_trend"] = np.where(
            df["x_dentrend"] == 0,
            0,
            df["_popwgt_nw"] / df["x_dentrend"]
        )
        return data
    
    def _post_processing(self, noised_data):
        df = noised_data["aeapp_protests_table_1"]
        # equalize pop within fips
        df["_popwgt_nw"] = df.groupby("fips")["_popwgt_nw"].transform("first")
        df["_popwgt_w"] = df.groupby("fips")["_popwgt_w"].transform("first")
        # ensure that _popwgt_nw + _pop
        df["_popwgt"] = df["_popwgt_nw"] + df["_popwgt_w"]
        df["x_dentrend"] = np.where(
            df["mileage_per_trend"] == 0,
            df["x_dentrend"],
            df["_popwgt_nw"] / df["mileage_per_trend"]
        )
        df["x_blacktrend"] = df["trend"] * df["_popwgt_nw"] / df["_popwgt"]
        return noised_data

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `eventstudy_AEAPP_tables.do`: ###
        # use "source/data/aeapp_protests_table_1.dta", clear
        # xtset fips year
        # ...
        # *non-white deaths 1) year effects  2) region by year effects  3) region by year  and covariates
        # ...
        # eststo: xtreg deaths_nw_police _S* _U*  x_* _O* [w=_popwgt_nw], cluster(fips) fe
        
        sensitivities = {
            ### deaths_nw_police: Non-White Police Deaths
            "deaths_nw_police": lambda countyyear: 1,

            ### _popwgt_nw: Population Weight based on 1960 Total Population Non-White
            # appears to be in 1's
            "_popwgt_nw": {
                "sensitivity": lambda countyyear: 1,
                "lb": 0
            },
            
            ### x_*
            # NOTE: assuming that trend is not personal; not sure what this is
            ## x_blacktrend:    % pop black x trend
            # x_blacktrend = _popwgt_nw / _popwgt * trend
            # NOTE: reconstructing trend = x_blacktrend * _popwgt / _popwgt_nw

            ## x_dentrend:      pop per sq mile x trend
            # assuming x_dentrend = _popwgt / mileage * trend = _popwgt / mileage_per_trend
            # NOTE reconstructing mileage_per_trend = _popwgt / x_dentrend
            # NOTE reconstructing _popwgt = _popwgt_nw + _popwgt_w
            "_popwgt_w": lambda countyyear: 1,

            ## x_uetrend:       LFPR Unemp x trend
            # NOTE: no info about emp, lf, cannot determine sensitivity
            
            ## x_pubtranstrend: % worker public tran x trend
            # NOTE: no info about emp, lf, cannot determine sensitivity

            ## x_povertytrend:  % faminc < 3K x trend
            # NOTE: assuming pop == num families
            # x_povertytrend = n_low_inc / _popwgt * trend
            # NOTE not enough info to separate n_low_inc from trend

            ## x_whiteinctrend: med fam inc white x trend
            # NOTE not enough info to separate med fam inc white from trend

            ## x_blackinctrend: med fam inc blk x trend
            # NOTE not enough info to separate med fam inc blk from trend

            ## x_pubasstrend:   #pub asst recipients x trend
            # NOTE: not enough info to separate pub asst recipients from trend

            ## x_owntrend:      black owner occupied x trend
            # NOTE: not enough info to separate black owner occupied from trend

            # [not personal] _U*：dummy variables for urban and year interaction terms
            # [not personal] _O*: dummy variable for pre/post treatment group from -1 to 4
            # [not personal]  _S*: dummy variables for stfips and year interaction terms
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        pretreatment = Result.from_esttab(
            id="pretreatment",
            table=table,
            row="_Ojoint_2",
            col="est1"
        )
        uprise=Result.from_esttab(
            id="uprise-death",
            table=table,
            row="_Ojoint_4",
            col="est1",
            expected_range=(pretreatment.est, None)
        )
        results.append(uprise)
        fourtosix=Result.from_esttab(
            id="uprise-4to6",
            table=table,
            row="_Ojoint_5",
            col="est1",
            expected_range=(uprise.est, None)
        )
        results.append(fourtosix)
        seventonine=Result.from_esttab(
            id="uprise-7to9",
            table=table,
            row="_Ojoint_6",
            col="est1",
            expected_range=(fourtosix.est, None)
        )
        results.append(seventonine)
        return results