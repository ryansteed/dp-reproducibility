from typing import Dict
from decimal import Decimal
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Acconcia(Study):
    id = 'acconcia-2014'

    def data_paths(self) -> dict:
        return {
            "ACCOSI_AER_DATA_MAFIA_PUBLIC_SPENDING": os.path.join(
                self.path(), "source/data", "ACCOSI_AER_DATA_MAFIA_PUBLIC_SPENDING.dta"
            ),
            # "post_replication": os.path.join(
            #     self.path(), "source/data", "post_replication.dta"
            # ), # for monitoring purposes, created by us
            # ...
        }
    
    def vars_to_noise(self):
        # list all personal vars used in the regression
        return {
            "pre_replication": [
                "Y",
                "G",
                "Mafiosi",
                "Murder",
                "Extortion",
                "Corruption1",
                "Corruption2",
                "Population"
            ],
            "post_replication": [
                "L1G",
                "L2G",
                "L1Y",
                "L2Y",
                "L1Mafiosi",
                "L2Mafiosi",
                "L1Extortion",
                "L2Extortion",
                "L1Corruption1",
                "L2Corruption1",
                "L1Corruption2",
                "L2Corruption2",
                "L1Murder",
                "L2Murder",
                ## could not noise
                # "L1U1",
                # "L1U2",
                # "L2U1",
                # "L2U2"
            ]
        }
    
    def _pre_processing(self, data):
        for k in data.keys():
            df = data[k]

            pop_ratio = df["Population"].astype('float64') / df["Population"].astype('float64').shift(1)
            df["value_ratio"] = (df["Y"].astype('float64') + 1) / pop_ratio
            df["infra_ratio"] = (df["G"].astype('float64') + 1) / pop_ratio

            self._crimevars = [
                "Mafiosi",
                "Murder",
                "Extortion",
                "Corruption1",
                "Corruption2"
            ]
            for crimevar in self._crimevars:
                df[f"{crimevar}_diff"] = df[crimevar].astype('float64') * df["Population"].astype('float64') / 1000

            data[k] = df
        return data
    
    def _post_processing(self, noised_data):
        for k in noised_data.keys():
            df = noised_data[k]

            pop_ratio = df["Population"].astype('float64') / df["Population"].astype('float64').shift(1)
            df["Y"] = np.where(
                pop_ratio.isna(),
                df["Y"], # authors did not provide a pop value for the base year, so just impute
                df["value_ratio"].astype('float64') * pop_ratio - 1
            )
            df["G"] = np.where(
                pop_ratio.isna(),
                df["G"], # authors did not provide a pop value for the base year, so just impute
                df["infra_ratio"].astype('float64') * pop_ratio - 1
            )

            for crimevar in self._crimevars:
                df[crimevar] = df[f"{crimevar}_diff"].astype('float64') / df["Population"].astype('float64') * 1000

            noised_data[k] = df
        return noised_data

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `ACCOSI_AER_STATA_PROGRAM_MAFIA_PUBLIC_SPENDING.do`: ###
        # use "ACCOSI_AER_DATA_MAFIA_PUBLIC_SPENDING.dta", clear
        # tsset Id Year
        # ...
        # local Controls L1U1 L1U2 L2U1 L2U2 L2CD L3CD Mafiosi Extortion Corruption1 Corruption2 Murder L1Mafiosi L1Extortion L1Corruption1 L1Corruption2 L1Murder L2Mafiosi L2Extortion L2Corruption1 L2Corruption2 L2Murder
        # ...
        # eststo: ivreg2 Y (G = CD_S1 L1CD_S2) L1G L2G `Controls' [w=Pop] if Year>=1990 & Year<=1999, first partial(`Controls') cluster(Group)
        # ...
        # eststo: ivreg2 Y (G = CD_S1 L1CD_S2) L1G L2G L1Y L2Y `Controls' [w=Pop] if Year>=1990 & Year<=1999, first partial(`Controls') cluster(Group)
        #
        ###
        
        sensitivities = {
            ### Population: province population   
            "Population": {
                "sensitivity": lambda provinceyear: 1,
                "lb": 1
            },

            ### Y: The year-on-year change in per capita real value added divided by the previous year’s per capita real value added
            # assuming Y = (v_1 / pop_1 - v_0 / pop_0) * pop_0 / v_0
            # = (v_1 * pop_0) / (v_0 * pop_1) - 1
            # = (v_1 / v_0) * (pop_1 / pop_0) - 1
            # NOTE: reconstructing value_ratio = (Y + 1) / pop_ratio
            # value ratio not personal, treat as constant
            # population already noised

            ### G: G(t) is the dated t year-on-year change in per capita real infrastructure investment (nominal spending divided by the national GDP deflator) divided by the previous year’s per capita real value added.
            # assuming G = (I_1 / pop_1 - I_0 / pop_0) * pop_0 / v_0
            # NOTE: reconstructing infra_ratio = (G + 1) / pop_ratio
            # population already noised
            

            ### crime variables: First difference of the number of people reported by the police forces for crime X, per 1000 population.
            # assuming Crime = (ncrime_1 / pop_1 - ncrime_0 / pop_0)
            # not enough info to reconstruct
            # assuming Crime = (ncrime_1 - ncrime_0) / pop_0 * 1000
            # NOTE: assuming common denominator (pop_0), reconstructing crime_diff = ncrime_1 - ncrime_0 = Crime * pop_0 / 1000
            # population already noised
            # diff has sensitivity 2
            ## Mafiosi: First difference of the number of people reported by the police forces to the judicial authority because of mafia-type association (art. 416-bis of the Italian penal code), per 1000 population.
            "Mafiosi_diff": lambda provinceyear: 2,
            ## Murder: First difference of the number of people reported by the police forces to the judicial authority because of murders related to the activity of maÖa associations, per 1000 population
            "Murder_diff": lambda provinceyear: 2,
            ## Extortion: First difference of the number of people reported by the police forces to the judicial authority because of extortion, per 1000 population.
            "Extortion_diff": lambda provinceyear: 2,
            ## Corruption1: First difference of the number of people reported to the judicial authority because of corruption, deÖned as to include embezzlement, misappropriation of public funds, extortion and bribery agreements, per 1000 population
            "Corruption1_diff": lambda provinceyear: 2,
            ## Corruption2: Second difference of the number of crimes reported to the judicial authority because of corruption, deÖned as to include embezzlement, misappropriation of public funds, extortion and bribery agreements, per 1000 population
            "Corruption2_diff": lambda provinceyear: 2,

            ### L`y'`v'
            # foreach j in G Y U1 U2 Mafiosi Extortion Corruption1 Corruption2 Murder {
            # g L1`j'=L1.`j'
            # g L2`j'=L2.`j'
            # }
            ## L1G: G(t-1) the lagged values of G
            # G already noised
            ## L2G: G(t-2) the lagged values of G
            # G already noised
            ## L1Y: lagged values of Y
            # Y already noised
            ## L2Y: lagged values of Ys
            # Y already noised
            ## L1Corruption1 
            # already noised
            ## L1Corruption2
            # already noised
            ## L2Corruption1
            # already noised 
            ## L2Corruption2
            # already noised
            ## L1Murder
            # already noised
            ## L2Murder
            # already noised
            ## L1Mafiosi
            # already noised
            ## L2Mafiosi  
            # already noised
            ## L1Extortion
            # already noised
            ## L2Extortion
            # already noised

            ## L1U1, L1U2: Lagged value of Change in the log of per-capita employment 
            # NOTE: cannot reconstruct; because log, can only reconstruct ratio, not diff
            ## L1U2, L2U2: Lagged value of Change in the log of per-capita hours of wage supplement provided by the unemployment insurance scheme available to employees of large private Örms in Italy.
            # NOTE: cannot reconstruct; because log, can only reconstruct ratio, not diff

            ### [not personal] L*CD: lagged value of CD: Number of municipalities placed under the administration of external commissioners (compulsory administration) by the central government on evidence of ties between administrators and the maÖas, either through the direct inÖltration of mobsters among local bureaucrats and/or politicians or through indirect ináuence, weighted by the share of the province population living in these munici
            ### [not personal] CD_S1: Same as CD, provided that the o¢ cial decree is published in the Örst semester of 
            ### [not personal] L1CD_S2: : Lagged value of CD_S2, CD_S2: Same as CD, provided that the average number of days between the dismissal of the city council and the year end is less than 180.
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        g_result = Result.from_esttab(
            id="add-out",
            table=table,
            row="G",
            col="est2",
            expected_range=Result.relative_range(1.5, tolerance=0.3)
        )
        results.append(g_result)
        lag_result = Result.from_esttab(
            id="lagadd-out",
            table=table,
            row="L1G",
            col="est2",
            expected_range=(0, None)
        )
        results.append(lag_result)
        # multiplier = G(t) / (1 + coeff on Y(t-1)) = 1.9 in paper
        # so, expecting 1.95 = G(t) / (1 + Y(t-1))
        # then Y(t-1) = G(t) / 1.9 - 1
        results.append(Result.from_esttab(
            id="lagout-out",
            table=table,
            row="L1Y",
            col="est2",
            expected_range=Result.relative_range(float(g_result.est) / 1.9 - 1, tolerance=0.2)
        ))
        return results