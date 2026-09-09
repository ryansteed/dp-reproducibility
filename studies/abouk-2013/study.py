from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Abouk(Study):
    id = 'abouk-2013'

    def data_paths(self) -> dict:
        return {
            "estdata": os.path.join(
                self.path(), "source/replication", "estdata.dta"
            )
            # ...
        }
    
    def _pre_processing(self, data):
        df = data["estdata"]
        df["Male"] = df["permale2"] / 100 * df["pop"]
        # df["unemp_num"] = df["unemp"] / 100 * df["pop"]
        return data
    
    def _post_processing(self, noised_data):
        noised_df = noised_data["estdata"]
        noised_df["lpop"] = np.log(noised_df["pop"])
        noised_df["permale2"] = noised_df["Male"] / noised_df["pop"] * 100
        # noised_df["unemp"] = noised_df["unemp_num"] / noised_df["pop"] * 100
        noised_df["laccidentsvso2"] = np.log(noised_df["accidentsvso"]+1)
        return noised_data
    
    def vars_to_noise(self) -> list:
        # list all personal vars used in the regression
        return [
            "pop",
            "lpop",
            "permale2",
            # "lnunemp",
            "laccidentsvso2"
        ]   

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `results.do`: ###
        # use estdata
        # ...
        # *Table 3
        # *-------------------
        # ...
        # eststo main: reg laccidentsvso2 strongban weakban lpop lunemp permale2  lrgastax st1-st50 t1-t48 [aweight=pop],cluster(state)
        
        ## NOTE: Some of the generation codes are from createdata.do, but I remove this do file from the Makefile
        ## because the code list below for pop, lunemp, and permale2, the createdata.do will cover all the noised data.
        ###
        sensitivities = {         
            ### pop: population in the state
            #> relevant regression code from `createdata.do` (not run):
            #> generate pop=0
            #> replace pop=	4661900	if	st1	==1	& year==	2007
            #> replace pop=	683478	if 	st2	==1	& year==	2007
            #> replace pop=	6338755	if	st3	==1	& year==	2007
            "pop": {
                "sensitivity": lambda state: 1,
                "lb": 1  # weighting var
            },

            ### lpop:  log of the population in the state
            #> relevant regression code from `createdata.do` (not run):
            #> generate lpop=log(pop)
            # NOTE: reconstructed lpop = log(pop)

            ### laccidentsvso2: log (number of fatal accidents + 1) for state i in month m
            # NOTE reconstructed laccidentsvso2 = log(accidentsvso + 1)
            "accidentsvso": lambda state: 1,

            ### lunemp: unemployment rate in the state
            #> relevant regression code from `createdata.do` (not run):
            #> gen unemp=0
            #> replace unemp=	3.3	if	year==	2007	&	mon1	==1	&	st1==1
            #> replace unemp=	3.3	if	year==	2007	&	mon2	==1	&	st1==1
            #> replace unemp=	3.3	if	year==	2007	&	mon3	==1	&	st1==1
            # NOTE: labor force / employment not provided, can't noise

            ### permale2:  proportion male in the state
            #> relevant regression code from `createdata.do` (not run):
            #> gen permale=0
            #> replace permale=	0.48422477	if	year==2007	&	st1	==1
            #> replace permale=	0.520645701	if	year==2007	&	st2	==1
            # NOTE: created var Male = permale2*pop
            "Male": lambda state: 1,
            # pop already noised

            ### (not personal) lrgastax:
            #> gen rgastax=gastax/cpi
            #> gen lrgastax=ln(rgastax)

            ### (not personal) st1-st50: state dummy variable
            ### (not personal) t1-t48: time variable

            ### (not personal) strongban: whether a strong texting ban in the state
            #> gen strongban= second~=1 & agelimit~=1 & txmsban==1

            ### (not personal) weakban: whether a strong texting ban in the state
            #> gen weakban= strongban==0 & txmsban==1

            ### (not personal) txmsban: whether a state has a texting ban in place in a month 

        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="strong-accident",
            table=table,
            row="strongban",
            col="main",
            expected_range=(None, 0),
            est_stats={"est": "b", "se": "se"}
        ))
        results.append(Result.from_esttab(
            id="weak-accident",
            table=table,
            row="weakban",
            col="main",
            expected_range=(0, None),
            est_stats={"est": "b", "se": "se"}
        ))
        return results