from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Lundqvist(Study):
    id = 'lundqvist-2014'

    def data_paths(self) -> dict:
        return {
            "municipaldata": os.path.join(
                self.path(), "source/ReplicationData", "municipaldata.dta"
            ),
            "finaldata": os.path.join(
                self.path(), "source/ReplicationData", "finaldata.dta"
            ) # created by authors, included for monitoring
            # ...
        }
    
    def vars_to_noise(self):
        # list all personal vars used in the regression
        return {
            "post_replication": [
                "pers_total",
                "pers_admin",
                "pers_child",
                "pers_school",
                "pers_elder",
                "pers_social",
                "pers_tech",
                "forcing1",
                "Dforcing1"
            ]
        }
    
    def _pre_processing(self, data):
        self._pc_vars = [
            "total",
            "admin",
            "child",
            "school",
            "elder",
            "social",
            "tech"
        ]
        for key in self.data_paths().keys():
            df = data[key]
            for v in self._pc_vars:
                df[f"n_{v}"] = df[f"pers_{v}"] * df["pop"] / 1000
            df["pop_12"] = df["pop"].astype('float64').shift(2) / (1 - df["popchange_10y"].astype('float64') / 100)
            data[key] = df
        return data
    
    def _post_processing(self, noised_data):
        for key in self.data_paths().keys():
            df = noised_data[key]
            for v in self._pc_vars:
                df[f"pers_{v}"] = df[f"n_{v}"] / df["pop"] * 1000
            pop_2 = df["pop"].astype('float64').shift(2)
            df["popchange_10y"] = np.where(
                pop_2.isna(),
                df["popchange_10y"].astype('float64'), # missing base years, just keep original
                100 * (1 - pop_2 / df["pop_12"].astype('float64'))
            )
            noised_data[key] = df
        return noised_data

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `create_data.do`: ###
        # use "municipaldata.dta", clear
        # sort code year
        # merge 1:1 code year using "IFAU_pers.dta"
        # drop _merge
        # merge 1:1 code year using "outsourced_pers.dta"
        # drop _merge
        # ...
        # save "finaldata.dta", replace
        ###
        ### relevant regression code from `estimations.do`: ###
        # use "finaldata.dta", clear
        # ...
        # *Table 3: Effects of grants on municipal personnel (2SLS estimates)
                
        # foreach outcome in pers_total pers_admin pers_child pers_school pers_elder pers_social pers_tech {
        # forvalues p=1/3 {
        # eststo `outcome'`p': xi: ivreg2 `outcome' (costequalgrants = Dforcing1) forcing1-forcing`p' i.year, cluster(code) icomp
        # ...
        # }
        # ...
        # }
        # }
        ###

        sensitivities = {
            ### pers_*: personall per 1,000 capita
            # assuming pers_* = n_* / pop * 1000
            # NOTE: reconstructing n_* = pers_* * pop / 1000
            "pop": lambda muncipalityyear: 1,
            ## pers_total: "Personnel, total (full-time equivalents per 1,000 capita)"
            "n_total": lambda muncipalityyear: 1,
            ## pers_admin: "Personnel, administration"
            "n_admin": lambda muncipalityyear: 1,
            ## pers_child: "Personnel, child care"
            "n_child": lambda muncipalityyear: 1,
            ## pers_school: "Average monthly wage, schools"
            "n_school": lambda muncipalityyear: 1,
            ## pers_elder: "Personnel, elderly care"
            "n_elder": lambda muncipalityyear: 1,
            ## pers_social: "Personnel, social welfare"
            "n_social": lambda muncipalityyear: 1,
            ## pers_tech: "Personnel, technical services"
            "n_tech": lambda muncipalityyear: 1,

            ### forcing1: "the out-migration term with polynomial p = 1"
            #> from create_data.do:
            # gen outmigration=-popchange_10y
            # replace outmigration=round(outmigration,.01)
            # gen forcing=outmigration-2
            # ...
            # forvalues i=1/3 {
            #     gen forcing`i'=forcing^(`i')
            #     }
            #>
            # popchange_10y: 10 year out-migration, lagged 2 years
            # [paper p. 171] The assignment variable mi, t is thepercentage decrease in the size of the population ni, t during a ten-year period with a two-year lag, i.e., mi, t = 100(1 − ni, t−2/ni, t−12).
            # popchange_10y = 100 * (1 - pop_{t-2} / pop_{t-12})
            # NOTE: reconstructing pop_2 = pop.shift(2), imputing first two years
            # already noised pop
            # NOTE: reconstructing pop_12 = pop_2 / (1 - popchange_10y / 100)
            "pop_12": lambda muncipalityyear: 1,
            
            ### Dforcing1: "k=2 is the kind point, the interaction term D is an indicator for out-migration rates above the kink point"
            #> from create_data.do:
            # gen D=(outmigration>2)
            # gen Dforcing1=D*forcing
            # replace Dforcing1 = round(Dforcing1)
            #>
            # forcing already noised above

            ### [not personal] costequalgrants: cost equalizing grants


            ### [not used] h15: "Different bandwidths"
            ### [not used] h10: "Different bandwidths"
            ### [not used] h5: "Different bandwidths"
            # *Different bandwidths, h
            # foreach i in 5 10 15 {
            # gen h`i'=0
            # replace h`i'=1 if forcing>=-`i' & forcing<=`i'
            # }
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="grant-publicemp",
            table=table,
            row="costequalgrants",
            col="pers_total1",
            expected_range=(0, 0)
        ))
        results.append(Result.from_esttab(
            id="grant-adminemp",
            table=table,
            row="costequalgrants",
            col="pers_admin1",
            expected_range=(0, None)
        ))
        results.append(Result.from_esttab(
            id="grant-childcareemp",
            table=table,
            row="costequalgrants",
            col="pers_child1",
            expected_range=(0, 0)
        ))
        results.append(Result.from_esttab(
            id="grant-schoolemp",
            table=table,
            row="costequalgrants",
            col="pers_school1",
            expected_range=(0, 0)
        ))
        results.append(Result.from_esttab(
            id="grant-elderlycareemp",
            table=table,
            row="costequalgrants",
            col="pers_elder1",
            expected_range=(0, 0)
        ))
        results.append(Result.from_esttab(
            id="grant-welfareemp",
            table=table,
            row="costequalgrants",
            col="pers_social1",
            expected_range=(0, 0)
        ))
        results.append(Result.from_esttab(
            id="grant-technicalemp",
            table=table,
            row="costequalgrants",
            col="pers_tech1",
            expected_range=(0, 0)
        ))
        return results