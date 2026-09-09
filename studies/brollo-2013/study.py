from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Brollo(Study):
    id = 'brollo-2013'

    def data_paths(self) -> dict:
        return {
            "AER_smallsample": os.path.join(
                self.path(), "source/AER_Political_Resource_Curse_DATA", "AER_smallsample.dta"
            ),
             "AER_largesample": os.path.join(
                self.path(), "source/AER_Political_Resource_Curse_DATA", "AER_largesample.dta"
            )
            # ...
        }
    
    def vars_to_noise(self) -> list:
        # list all personal vars used in the regression
        return [
            "pop",
            "pop_2",
            "pop_3",
            # "fpm_hat"
        ]
    
    # def _pre_processing(self, data):
    #     return data
    
    def _post_processing(self, noised_data):
        for key in noised_data.keys():
            df = noised_data[key]
            df["pop_2"] = np.power(df["pop"], 2)
            df["pop_3"] = np.power(df["pop"], 3)
        return noised_data

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `PRC_AER_Tab5.do`: ###
        # use AER_smallsample,clear
        # *thresholds 1-7:
        #-- fpm-board
        # *column (1) - Broad corruption
        # eststo: xi: ivreg2 broad pop pop_2 pop_3 (fpm=fpm_hat) i.term i.regions,r cluster(id_city)
        #-- fpm-narrow
        # *column (2) - Narrow corruption
        # eststo: xi: ivreg2 narrow pop pop_2 pop_3 (fpm=fpm_hat) i.term i.regions,r cluster(id_city)

        ### relevant regression code from `PRC_AER_Tab9.do`: ###
        # use AER_largesample,clear
        # *thresholds 1-7:
        #-- fpm-college
        # eststo: xi: ivreg2 opp_college pop pop_2 pop_3 (fpm=fpm_hat) i.term i.regions,r cluster(id_city)
        # ...
        #-- fpm-school
        # foreach var in opp_yschool ... {
        # eststo: xi: ivreg2 `var' pop pop_2 pop_3 (fpm=fpm_hat) i.term i.regions,r cluster(id_city)
        # ...
        # }

        sensitivities = {
            ### pop: "population estimate"
            "pop": lambda cityterm: 1,
            ### pop_2: "populations estimate ^2"
            # NOTE: reconstructed pop_2 = pop ** 2
            ### pop_3: "populations estimate ^3"
            # NOTE: reconstructed pop_3 = pop ** 3
            ### [not personal] opp_college: "fraction of opponents with at least college degree"
            # refers to political candidates; public info
            ### [not personal] opp_yschool: average years of schooling of the pool of opponents
            # refers to political candidates; public info
            ### [not personal] fpm: actual fpm transfers
            # municipal transfers; not per capita
            ### fpm_hat: "theoretical fpm transfers" --- function of population
            # [paper] In theory, the amount of transfers each municipality receives should be calculated according to the IBGE population estimates that are sent to TCU in the previous year. Therefore, for the term 2001–2004, we use an average of the IBGE population estimates for the years 2000, 2001, and 2002; for the term 2005–2008, we use estimates for the years 2004, 2005, and 2006.
            # NOTE: earlier population estimates not included; cannot reconstruct

            ### [not personal] broad: "=1 if at least one (broad) corruption episode is reported"
            # these are audit reoprts, not individaul reports
            ### [not personal] narrow: "=1 if at least one (narrow) corruption episode is reported"
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="fpm-board",
            table=table,
            row="fpm",
            col="est1",
            expected_range=(0, None)
        ))
        results.append(Result.from_esttab(
            id="fpm-narrow",
            table=table,
            row="fpm",
            col="est2",
            expected_range=(0, None)
        ))
        table = self._load_esttab(f"{self.path()}/results/table2.csv")
        results.append(Result.from_esttab(
            id="fpm-college",
            table=table,
            row="fpm",
            col="est1",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="fpm-school",
            table=table,
            row="fpm",
            col="est2",
            expected_range=(None, 0)
        ))
        return results