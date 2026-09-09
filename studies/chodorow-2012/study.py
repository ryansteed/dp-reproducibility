from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import os


class Chodorow(Study):
    id = 'chodorow-2012'

    def data_paths(self) -> dict:
        return {
            # "state_medicaid_spending_instrument": os.path.join(
            #     self.path(), "source", "20100254_data","data", "state_medicaid_spending_instrument.dta"
            # ), 
            "pop16plus_cleaned": os.path.join(
                self.path(), "source", "20100254_data","data", "pop16plus_cleaned.dta"
            ),
            # "state_controls": os.path.join(
            #     self.path(), "source", "20100254_data","data", "state_controls.dta"
            # ),
            "totalempjune82011": os.path.join(
                self.path(), "source", "20100254_data","data","CES", "totalempjune82011.dta"
            ),
            "edhealthjune82011": os.path.join(
                self.path(), "source", "20100254_data","data","CES", "edhealthjune82011.dta"
            ),
            "totalgovjune82011": os.path.join(
                self.path(), "source", "20100254_data","data","CES", "totalgovjune82011.dta"
            )
            # ...
        }
    
    def vars_to_noise(self):
        return {
            "post_replication": [
                "popestimate2008",
                "popestimate2008_bil",
                "gdp_pc",
                # "per_empl_manu_10000",
                "sachange_totalemp_pc",
                "sachange_totalemp_lag_pc",
                "sachange_gov_broad_pc",
                "sachange_gov_broad_lag_pc",
                # "share_kerry_10000",
                # "union_share_10000",
                "instrument_pc",
                "fmap_pc",
            ]
        }
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `MainTables.do`: ###
        # use data/state_medicaid_spending_instrument, replace
        # ...
        # merge state_abrev using `pop16plus_cleaned', unique
        # ...
        # merge state_abrev using data/state_controls
        # ...
        # local regions "region_1 region_2 region_3 region_4 region_5 region_6 region_7 region_8 region_9"
        # ...
        # foreach level in totalemp gov_broad {
        # ...
        # local control3 "`regions' share_kerry_10000 union_share_10000 gdp_pc per_empl_manu_10000 popestimate2008_bil sachange_`level'_lag_pc"
        # foreach X in `endog' {
        #     ...
        #     *	Then IV	
        #     forvalues i=1/`rhs_iterations' {
        #         ivregress 2sls sachange_`level'_pc `control`i'' (`X' = instrument_pc) , robust
        #           ...
        #         }
        #     }
        # }
        ###
        vars_to_noise = {
            #--- pop16plus_cleaned
            ### popestimate2008: population estimate 2008
            #> from MainTables.do (run):
            # merge state_abrev using `pop16plus_cleaned', unique
            # replace pop16plus = pop16plus*1000
            # rename pop16plus popestimate2008
            #>
            # pop16plus: population 16+ in a state, in thousands
            "pop16plus": lambda state: 1/1000,

            ### popestimate2008_bil: population estimate 2008 in billions
            #> from MainTables.do (run):
            # gen popestimate2008_bil = popestimate2008/1000000000
            #>
            # popestimate2008 noised above

            ### gdp_pc: GDP per capita divided by 10000
            #> from MainTables.do (run):
            # qui gen gdp_pc = 1000000*gdp_2008/popestimate2008
            #>
            # gdp_2008 invariant
            # popestimate2008 noised above

            ### instrument_pc: FMAP Instrument (100k)
            # state’s Medicaid spending in fiscal year 2007, normalized by the 16+ population
            #> from MainTables.do (run):
            # capture qui gen `var'_pc = `var'/popestimate2008
            #>
            # [not personal] instrument: Total Payments Computable for Federal Funding
            # popestimate2008 noised above

            ### fmap_pc: ARRA FMAP Payouts per capita ($100k)
            #> from MainTables.do (run):
            # qui gen fmap = outlaysFMAP
            # capture qui gen `var'_pc = `var'/popestimate2008
            #>
            # [not personal] outlaysFMAP: FMAP outlays
            # already noised popetimate2008
            #---

            #--- state_controls
            ### per_empl_manu_10000: per_empl_manu/10000
            #> from MainTables.do (run):
            # gen per_empl_manu_10000 = per_empl_manu/10000
            #>
            # per_empl_manu: Employment manufacturing share
            # NOTE: total employment not included, not enough info for DP

            ### share_kerry_10000: share kerry / 10000
            #> from MainTables.do (run):
            # gen share_kerry_10000 = share_kerry/10000
            #>
            # share_kerry: 2004 Kerry share
            # NOTE: total # voters not provided, not enough info for DP

            ### union_share_10000: union share/ 10000
            # based on union_share
            # NOTE: denominator not provided, not enough info for DP
            #---

            #--- CES/`level'`vintage'
            #> from MainTables.do (run):
            # local start 7
            # local year_0 2008
            # local month_0 12
            # local year_1 2009
            # local month_1 `start'
            # ...
            # local l_year_0 2008
            # local l_month_0 5
            # local l_year_1 2008
            # local l_month_1 12
            # ...
            # local vintage june82011
            # ...
            # foreach level in totalemp totalgov edhealth education health {
            # use data/CES/`level'`vintage', replace
            # qui drop if state_abrev==""
            # qui gen sachange_`level' = 1000*(_`year_1'`month_1' - _`year_0'`month_0') 
          	# gen sachange_`level'_lag = 1000*(_`l_year_1'`l_month_1' - _`l_year_0'`l_month_0') 
            # ...
            # foreach level in totalemp totalgov edhealth education health {
            # gen sachange_`level'_pc = sachange_`level'/popestimate2008 
            # gen sachange_`level'_lag_pc = sachange_`level'_lag/popestimate2008
            # gen `level'_baseline_pc = baseline`level'/popestimate2008
            # }
            #>
            # popestimate2008 already noised

            #-- totalempjune82011
            ### sachange_totalemp_pc: seasonally adjusted change in total nonfarm employment per individual 16+ in a state, from December 2008 to July 2009
            # _20097: total nonfarm employment in July 2009, appears to be in 1000s
            "_20097": lambda state:  1/1000,
            # _200812: total nonfarm employment in December 2008, appears to be in 1000s
            "_200812": lambda state: 1/1000,

            ### sachange_totalemp_lag_pc
            # _200812: total nonfarm employment in December 2008, appears to be in 1000s
            # already noised above
            # _20085: total nonfarm employment in May 2008, appears to be in 1000s
            "_20085": lambda state: 1/1000,
            #--
            
            #-- totalgovjune82011, edhealthjune82011
            ### sachange_gov_broad_pc: seasonally adjusted change in total employment in state and local government, health, and education per individual 16+ in a state, from December 2008 to July 2009
            #> from MainTables.do (run):
            # qui gen sachange_gov_broad_pc = sachange_totalgov_pc + sachange_edhealth_pc
            #>
            ## sachange_totalgov_pc: seasonally adjusted change in total employment in state and local government per individual 16+ in a state, from December 2008 to July 2009
            # same sensitivity as above; _20097, _200812 already noised
            ## sachange_edhealth_pc: seasonally adjusted change in total employment in health and education per individual 16+ in a state, from December 2008 to July 2009
            # same sensitivity as above; _20097, _200812 already noised
            
            ### sachange_gov_broad_lag_pc
            #> from MainTables.do (run):
            # qui gen sachange_gov_broad_lag_pc = sachange_totalgov_lag_pc + sachange_edhealth_lag_pc
            #>
            ## sachange_totalgov_lag_pc
            # same sensitivity as above; _200812, _20085 already noised
            ## sachange_edhealth_lag_pc
            # same sensitivity as above; _200812, _20085 already noised
            #--
            #---

            ### [not personal] region_*: region dummies

        }
        return vars_to_noise

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table_totalemp.csv")
        results.append(Result.from_esttab(
            id="ivtotal-fmap",
            table=table,
            row="fmap_pc",
            col="iv_3_totalemp_fmap_pc",
            expected_range=(0, None)
        ))
        table = self._load_esttab(f"{self.path()}/results/table_gov_broad.csv")
        results.append(Result.from_esttab(
            id="ivgov-fmap",
            table=table,
            row="fmap_pc",
            col="iv_3_gov_broad_fmap_pc",
            expected_range=(0, None)
        ))
        return results