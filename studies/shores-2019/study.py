from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Shores(Study):
    id = 'shores-2019'

    def data_paths(self) -> dict:
        return {
            "analysis_file": os.path.join(
                self.path(), "source", "analysis_file.dta"
            )
            # ...
        }
    
    def vars_to_noise(self) -> list:
        # list all personal vars used in the regression
        return [
            "laborforce2006",
            "unemployed_count2006",
            "poppoorchild2006",
            "tot2007",
            "blk2007",
            "wht2007",
            "hsp2007",
            "frl2007", 
            "wtmath",
            "wtela",
            "mn_allmath",
            "mn_allela",
            # "percap_income2006",
        ]
    
    def _pre_processing(self, data):
        df = data["analysis_file"]
        df["mn_allmath_total"] = df["mn_allmath"] * df["wtmath"]
        df["mn_allela_total"] = df["mn_allela"] * df["wtela"]
        return data
    
    def _post_processing(self, noised_data):
        df = noised_data["analysis_file"]
        df["mn_allmath"] = df["mn_allmath_total"] / df["wtmath"]
        df["mn_allela"] = df["mn_allela_total"] / df["wtela"]
        return noised_data

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `dofile.do`: ###
        # u "${dir1}/analysis_file.dta", clear
        # ...
        # save `sedaflat'
        # ...
        # u "${dir}/revenues_2003_2015.dta", clear
        # ...
        # merge m:1 conumINT using `sedaflat', gen(_seda)		
        # ...
        # glob covars2 "laborforce2006 unemployed_count2006 estab_count_priv_total2006 poppoorchild2006 percap_income2006 blk2007 wht2007 hsp2007 frl2007 tot2007"
        # ...
        # /* TABLE 5: Estimated Changes in Student Achievement */
        # u `seda', clear
        # foreach s in math ela {
        #     ...
        #     * MODEL 2: DOSE-RESPONSE+RECOVERY
        #     eststo `s'm2: reghdfe mn_all`s' i.recquar##c.exposureN##c.yearcenN [aw=wt`s'], abs(conum year##grade i.year#i.grade#c.(${covars2})) cluster(conum  year##grade) 
        #     ...
        # }	

        sensitivities = {
            ### wtmath: district enrollment (math)
            "wtmath": {
                "sensitivity": lambda district: 1,
                "lb": 1
            },

            ### wtela: district enrollment (ELA)
            "wtela": {
                "sensitivity": lambda district: 1,
                "lb": 1
            },

            ### mn_allmath: Average standardized math achievement score for Grades 3–8 students in a county-year from the SEDA dataset.
            # standardized to mean zero, sd 1
            # assuming mn_allmath = mn_allmath_total / wtmath
            # NOTE: created inter var mn_allmath_total = mn_allmath * wt
            # NOTE: assuming scores clipped at 3 std from mean
            # wtmath already noised
            "mn_allmath_total": lambda district: 3,

            ### mn_allela: Average standardized ELA achievement score for Grades 3–8 students in a county-year from the SEDA dataset.
            # standardized to mean zero, sd 1
            # assuming mn_allela = mn_allela_total / wtela
            # NOTE: created inter var mn_allela_total = mn_allela * totgyb_allela
            # NOTE: assuming scores clipped at 3 std from mean
            # wtela already noised
            "mn_allela_total": lambda district: 3,
            
            ### laborforce2006: labor force count
            "laborforce2006": lambda district: 1,
            
            ### unemployed_count2006: unemployment count
            "unemployed_count2006": lambda district: 1,
            
            ### poppoorchild2006: Children in poverty counts
            "poppoorchild2006": lambda district: 1,
            
            ### percap_income2006: per capita income
            # NOTE: population not given, can't noise

            ### blk2007: # of Grades 3 to 8 students who are Black
            "blk2007": lambda district: 1,
            
            ### wht2007: # of Grades 3 to 8 students who are White
            "wht2007": lambda district: 1,
            
            ### hsp2007: # of Grades 3 to 8 students who are Hispanic
            "hsp2007": lambda district: 1,
            
            ### frl2007: # of K–12 students qualifying for FRPL
            "frl2007": lambda district: 1,
            
            ### tot2007: total # of students
            "tot2007": lambda district: 1,
            
            ### (not personal)i.recquar: measure of recession intensity for county i, as described in Equation (1), which we convert into q quartiles.
            ### (not personal) c.exposureN: 
            #> replace exposureN = 0 if inlist(cohort,2010,2011,2012)
            #> replace exposureN = 1 if inlist(cohort,2001,2009)
            #> replace exposureN = 2 if inlist(cohort,2002,2003,2004,2005,2006,2007,2008)
            ### [not personal] estab_count_priv_total2006: business establishments counts
            ### [not personal] yearcenN
            #>
            # gen yearcenN = .
            # replace yearcenN = 0 if inlist(year,2009,2010)
            # *replace yearcenN = 0 if inlist(year,2009,2010,2011)
            # loc i = 0
            # forval y = 2011/2015 {
            # *forval y = 2012/2015 {
            #     loc ++i
            #     replace yearcenN = `i' if year==`y'
            #     }
            #     ta yearcenN, gen(recov_)
            #>
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="recession-math",
            table=table,
            row="4.recquar#c.exposureN",
            col="mathm2",
            expected_range=(None, 0),
            est_stats={"est": "b", "se": "se"}
        ))
        results.append(Result.from_esttab(
            id="recession-english",
            table=table,
            row="4.recquar#c.exposureN",
            col="elam2",
            expected_range=(None, 0),
            est_stats={"est": "b", "se": "se"}
        ))
        return results