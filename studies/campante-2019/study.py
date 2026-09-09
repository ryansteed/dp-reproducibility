from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Campante(Study):
    id = 'campante-2019'

    def data_paths(self) -> dict:
        return {
            "bygid_confdata": os.path.join(
                self.path(), "source", "bygid_confdata.dta"
            ),
            "AEJApplied_CrossCountryData": os.path.join(
                self.path(), "source", "AEJApplied_CrossCountryData.dta"
            ),
            # ...
        }
    
    def vars_to_noise(self) -> list:
        return [
            "avg_loggcppc",
            "avg_logpop",
            "imr",
            "lpop",
            "lgdppc",
            # "SP_URB_TOTL_IN_ZS",
            # "elf_eth",
        ]

    def _pre_processing(self, data):
        df = data["bygid_confdata"]
        # deconstruct avg_logpop
        df["pop_avg"] = np.exp(df["avg_logpop"])
        # deconstruct avg_loggcppc
        df["gcp_avg"] = np.exp(df["avg_loggcppc"]) * df["pop_avg"]
        data["bygid_confdata"] = df

        df = data["AEJApplied_CrossCountryData"]
        # deconstruct lpop
        df["pop_avg"] = np.exp(df["lpop"])
        # deconstruct lgdppc
        df["gdp_avg"] = np.exp(df["lgdppc"]) * df["pop_avg"]
        data["AEJApplied_CrossCountryData"] = df

        return data
    
    def _post_processing(self, noised_data):
        df = noised_data["bygid_confdata"]
        # reconstruct avg_logpop
        df["avg_logpop"] = np.log(df["pop_avg"])
        # reconstruct avg_loggcppc
        df["avg_loggcppc"] = np.where(
            df["pop_avg"].isna(),
            df["avg_loggcppc"],
            np.log(df["gcp_avg"] / df["pop_avg"])
        )
        noised_data["bygid_confdata"] = df

        df = noised_data["AEJApplied_CrossCountryData"]
        # reconstruct lpop
        df["lpop"] = np.log(df["pop_avg"])
        # reconstruct lgdppc
        df["lgdppc"] = np.log(df["gdp_avg"] / df["pop_avg"])
        noised_data["AEJApplied_CrossCountryData"] = df
        return noised_data
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `AEJApplied_ConflictRegressions.do`: ###
        #--- distance-conflict
        # global controls "avg_loggcppc avg_logpop imr logttime logcellarea avg_logdist_LNC"
        # global controls2 "${controls} mountain2000 ycoord avg_degtemper avg_prec" //not including forest2000
        # ...
        # use bygid_confdata, clear
        # keep if avg_polity2<=0
        # eststo: areg avg_ConfIntra avg_logcapdist ${controls2} , a(isocode) cluster(iso)
        ###
        ### relevant regression code from `AEJApplied_CrossCountryRegressions.do`: ###
        #--- distance-misgov
        # use "$DataFolder/AEJApplied_CrossCountryData.dta", clear
        # ...
        # eststo:reg zkkm_pcfirst_9612 zavglogdist90_adj lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth  reg_* leg_* if iso~="ZAF" & iso~="MUS"& iso~="MMR" & iso~="KAZ" & dup<2 & polity~=., robust
        ###
        sensitivities = {
            #--- bygid_confdata
            ### avg_logpop: log population averaged over time periods
            # NOTE: assuming averaging before log
            # avg_logpop = log(pop_avg)
            # NOTE: created var pop_avg = exp(avg_logpop)
            "pop_avg": lambda cell: 1,

            ### avg_loggcppc: log gross cell products per capita
            # NOTE: assuming averaging before log
            # avg_loggcppc = log(gcp_avg / pop_avg))
            # NOTE: created var gcp_avg = exp(avg_loggcppc) * pop_avg
            # pop_avg already noised

            ### imr: Infant mortality rate (deaths per 10000)
            # NOTE: assuming denominator invariant
            "imr": lambda cell: 1 / 10000,
            
            ### [not personal] avg_polity2: Average polity score (related to govt structure)
            ### [not personal] avg_ConfIntra: Average probability of conflict over cells
            ### [not personal] avg_logcapdist: Log distance of grid cell to the capital city
            ### [not personal] logttime: log travel time to the nearest urban area
            ### [not personal] logcellarea: log cell area
            ### [not personal] avg_logdist_LNC: log distance to the largest non-capital city
            ### [not personal] mountain2000: proportion of mountain area (all measured in 2000)
            ### [not personal] ycoord: cell latitude
            ### [not personal] avg_degtemper: average temperature
            ### [not personal] avg_prec: average precipitation

            #--- AEJApplied_CrossCountryData
            
            ### lpop: (mean) log population
            # NOTE: assuming averaging before log
            # NOTE: created var pop_avg = exp(lpop)
            # pop_avg already noised

            ### lgdppc: (mean) lgdppc
            # NOTE: assuming uses same pop as pop_avg, averaging before log
            # lgdppc = log(gdp_avg / pop_avg)
            # NOTE: created var gdp_avg = exp(lgdppc) * pop_avg
            # pop_avg already noised

            ### elf_eth: ethnic fractionalizaiton
            # NOTE: not enough info for DP

            ### SP_URB_TOTL_IN_ZS: urbanization?
            # NOTE: not enough info, probably not personal?
            ### [not personal] zkkm_pcfirst_9612
            #> from AEJApplied_CrossCountryRegression.do (run):
            # egen zkkm_pcfirst_9612=std(kkm_pcfirst_9612)
            #>
            # [not personal] kkm_pcfirst_9612: scores for component 1 of worldwide governance indicators
            ### [not personal] zavglogdist90_adj
            #> from AEJApplied_CrossCountryRegression.do (run):
            # gen avglogdist90_adj = 1-pcia_90
            # ...
            # egen zavglogdist90_adj=std(avglogdist90_adj)
            #>
            # [not personal] pcia_90: mean(pcia_90); measure of isolation
            ### [not personal] maj: majoritarian system dummy
            ### [not personal] pres: presidential system dummy
            ### [not personal] reg_*: region dummies
            ### [not personal] leg_*: legal origin dummies
            ### [not personal] iso: country code
            ### [not personal] dup: ??? duplicates
            ### [not personal] polity: polity score
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="distance-conflict",
            table=table,
            row="avg_logcapdist",
            col="est1",
            expected_range=(None, 0)
        ))
        table = self._load_esttab(f"{self.path()}/results/table2.csv")
        results.append(Result.from_esttab(
            id="distance-misgov",
            table=table,
            row="zavglogdist90_adj",
            col="est1",
            expected_range=(None, 0)
        ))
        return results