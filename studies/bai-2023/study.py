from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Bai(Study):
    id = 'bai-2023'

    def data_paths(self) -> dict:
        return {
            "county_panel": os.path.join(
                self.path(), "source/Data", "county_panel.dta"
            )
            # ...
        }
    
    def vars_to_noise(self) -> list:
        # list all personal vars used in the regression
        return [
            "pop1964",
            "lnpnapop",
            "y1964lnfracdeaths",
            "y1982lnfracdeaths",
            "y1990lnfracdeaths",
            "y2000lnfracdeaths"
            # "y1964Xln_ethf",
            # "y1982Xln_ethf",
            # "y1990Xln_ethf",
            # "y2000Xln_ethf",
            # "y1964Xln_gini",
            # "y1982Xln_gini",
            # "y1990Xln_gini",
            # "y2000Xln_gini"
        ]
    
    _years = ["1964", "1982", "1990","2000"]
    
    def _pre_processing(self, data):
        df = data["county_panel"]
                
        df["nonagr"] = df["pnapop"].astype('float64') * df["pop1964"].astype('float64') / 100
        df["deaths"] = (np.exp(df["lnfracdeaths"].astype('float64')) - 1) / 100 * df["pop1964"].astype('float64')

        return data
    
    def _post_processing(self, noised_data):
        df = noised_data["county_panel"]

        df["pnapop"] = df["nonagr"] / df["pop1964"] * 100
        df["lnpnapop"] = np.log(df["pnapop"] + 1)

        df["lnfracdeaths"] = np.log(1 + df["deaths"] / df["pop1964"] * 100)

        for year in self._years:
            # mask = df[f"y{year}"] == 1
            # df.loc[mask, f"y{year}lnfracdeaths"] = np.log(df.loc[mask, f"death{year}"] / df.loc[mask, "pop1964"] * 100 + 1)
            df[f"y{year}lnfracdeaths"] = df["lnfracdeaths"] * df[f"y{year}"]
        return noised_data

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `table_3.do`: ###
        # use county_panel.dta, clear
        # ...
        # local gini       y1964Xln_gini y1982Xln_gini y1990Xln_gini y2000Xln_gini
        # local ethf       y1964Xln_ethf y1982Xln_ethf y1990Xln_ethf y2000Xln_ethf
        # local char       y1964Xln_charity y1982Xln_charity y1990Xln_charity y2000Xln_charity
        # local terrain    y1964Xln_slp y1982Xln_slp y1990Xln_slp y2000Xln_slp
        # local distborder y1964Xln_provdist y1982Xln_provdist y1990Xln_provdist y2000Xln_provdist
        # local dist       y1964Xln_dist_pcap y1982Xln_dist_pcap  y1990Xln_dist_pcap  y2000Xln_dist_pcap 
        # local words      y1964Xlnwords1 y1964Xlnwords2 y1982Xlnwords1 y1982Xlnwords2 y1990Xlnwords1 y1990Xlnwords2 y2000Xlnwords1 y2000Xlnwords2
        # local deng       y1964Xdeng y1982Xdeng y1990Xdeng y2000Xdeng

        # ...
        # eststo main: areg lnpnapop  y1964 y1964lnfracdeaths y1982 y1982lnfracdeaths y1990 y1990lnfracdeaths y2000 y2000lnfracdeaths `char' `ethf'  `gini'  `terrain' `distborder' `dist' `prov_t' `words' `deng' [aw=pop1964]  if sample1953==1, absorb(cntygb) robust cluster(cntygb)

        ###
        sensitivities = {
            ### pop1964: 1964 population
            "pop1964": {
                "sensitivity": lambda county: 1,
                "lb": 1,
            },

            ### lnpnapop: Fraction of non-agricultural population(log)
            # NOTE reconstructing lnpnapop = log(pnapop + 1)
            # pnapop: % of non-agr population
            # assuming pnapop = nonagr / pop1964 * 100
            # NOTE reconstructing inter var nonagr = pnapop * pop1964 / 100
            # pop1964 already noised
            "nonagr": lambda county: 1,
            
            ### y*lnfracdeaths: Deaths(% of county pop.) x y* (log)
            # in paper: This figure maps revolutionary intensity at the county level, as proxied by revolution-related deaths as a proportion of 1964 population, formally Log(1 + deaths/population* 100). 
            # as proxied by revolution-related deaths as a proportion of 1964 population, 
            # formally Log(1 + deaths/population* 100).
            # NOTE: reconstructing y*lnfracdeaths = lnfracdeaths * y*
            # assuming lnfracdeaths = log(1 + deaths*100/pop1964)
            # NOTE: creating inter var deaths = (exp(lnfracdeaths) - 1) / 100 * pop1964
            # pop1964 already noised
            "deaths": lambda county: 1,
            ## y1964lnfracdeaths
            ## y1982lnfracdeaths
            ## y1990lnfracdeaths
            ## y2000lnfracdeaths

            ### y*Xln_ethf: Pre-CR Ethnic Fragmentation x D*
            # NOTE complex measure, equation not provided; cannot privatize

            ### y*Xln_gini: Pre-CR educational Inequality x D*
            # NOTE components not provided; cannot privatize
            
            ### (not personal) y*: Year = *
            ### (not personal)y*Xln_charity: Pre-CR Social Capital (num charity orgs) x D*
            ### (not personal) y*Xln_slp: Log Avg. Terrain Slope x D*
            ### (not personal) y*Xln_provdist: Log Dist. to Prov. Border x D*
            ### (not personal) y*Xln_dist_pcap: Log Dist. to Prov. Capital x D*
            ### (not personal) t_prov*: Province * time trend
            ### (not personal) y*Xlnwords1: Word Count in Chronicle x D*
            ### (not personal) y*Xlnwords2: Word Count in GPCR Section x D1964
            ### (not personal) y*Xdeng: Post-Deng Period Pub. x D*
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="revo-industry",
            table=table,
            row="y1982lnfracdeaths",
            col="main",
            expected_range=(None, 0)
        ))
        return results