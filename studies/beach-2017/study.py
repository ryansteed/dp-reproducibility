from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Beach(Study):
    id = 'beach-2017'

    def data_paths(self) -> dict:
        return {
            "Gridlock-main-data-for-analysis": os.path.join(
                self.path(), "source/POL2015-0394_data", "Gridlock-main-data-for-analysis.dta"
            ),
            # NOT USING — NOT ENOUGH INFO FOR DP
            # "Gridlock-voting-data-for-analysis": os.path.join(
            #     self.path(), "source/POL2015-0394_data", "Gridlock-voting-data-for-analysis.dta"
            # )
            # ...
        }
    
    def _pre_processing(self, data):
        df = data["Gridlock-main-data-for-analysis"]
        # deconstruct a_pg_pc
        df["a_pg"] = df["a_pg_pc"] * df["totpop"]
        # deconstruct share_pop_*
        self._ethshares = {
            "share_pop_nh_white": "white",
            "share_pop_h": "hisp",
            "share_pop_nh_black": "black",
            "share_pop_nh_asian": "asian",
            # "share_pop_nh_other": "other",
            # "share_pop_nh_natam": "natam",
        }
        self._stripindex = 10
        for sh in self._ethshares.keys():
            df[sh[self._stripindex:]] = df[sh] * df["totpop"]
        data["Gridlock-main-data-for-analysis"] = df
        return data
    
    def _post_processing(self, noised_data):
        df = noised_data["Gridlock-main-data-for-analysis"]
        # reconstruct ln_a_pg_pc
        df["a_pg_pc"] = df["a_pg"] / df["totpop"]
        df["ln_a_pg_pc"] = np.log(df["a_pg_pc"])
        # reconstruct share_pop_*
        for sh in self._ethshares.keys():
            df[sh] = df[sh[self._stripindex:]] / df["totpop"]
        # reconstruct nonmodal_wins
        self._ethwins = {
            "white_wins": "white",
            "hisp_wins": "hisp",
            "black_wins": "black",
            "asian_wins": "asian",
        }
        df["eth_modal"] = df[self._ethshares.keys()].idxmax(axis=1, skipna=True).replace(self._ethshares)
        df["eth_wins"] = None
        for ind, eth in self._ethwins.items():
            df.loc[df[ind] == 1, "eth_wins"] = eth
        df.loc[
            ~(df["eth_wins"].isna() | df["nonmodal_wins"].isna()),
            "nonmodal_wins"
        ] = (df["eth_modal"] != df["eth_wins"]).astype(int)
        errs = [
            462,  463,  468,  532,  533,  729,  788,  789, 1043, 1044, 1174, 1218,
            1268, 1372, 1373, 1388, 1528, 1676, 1690, 1691, 1913, 1929, 1943, 1944,
            2059, 2073, 2074, 2147, 2148, 2212, 2213, 2227, 2228, 2240, 2308
        ] # inexplicable errors in original — 35/2350
        if np.isclose(df["nonmodal_wins"].iloc[errs], [
            1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 1,
            0, 1, 1, 1, 1, 1, 1, 0, 0, 1, 0
        ]).all(): # fix inexplicable errors for control only
            df.loc[errs, "nonmodal_wins"] = 1 - df.loc[errs, "nonmodal_wins"]
        noised_data["Gridlock-main-data-for-analysis"] = df

        return noised_data
    
    def vars_to_noise(self) -> list:
        # list all personal vars used in the regression
        return {
            "pre_replication": [
                "ln_a_pg_pc",
            ],
            "post_replication": [
                "Margin",
                "DD_nonmodal_wins",
                # "treatXlow",
                # "treatXhigh",
                # "high",
            ]
        }

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `Main-results.do`: ###
        #--- nonmodal-spend
        # use "Gridlock-main-data-for-analysis.dta"
        # ...
      	# eststo m3: areg ln_a_pg_pc DD_nonmodal_wins##c.Margin i.datayear if Margin<.071  , a(ENTITY_ID) cluster(raceid4)
        #--- segregation-effect, inequality-effect
        # foreach x in MGdis theil ... {
        # ...
        # eststo T5_`x': areg ln_a_pg_pc  (treatXlow treatXhigh high)##c.Margin     i.datayear if Margin<.0713803, a(ENTITY_ID) cluster(raceid4)  
        # }
        ###
        ### relevant regression code from `Table-7.do`: ###
        # use "Gridlock-voting-data-for-analysis"
        # ...
        # eststo voting_1: areg voteshare DD_nonmodal_wins##c.Margin i.numcandidates i.year if Margin<.0713803 & haspre!=0, a(personid) cluster(raceid)
        ###
        sensitivities = {
            #--- Gridlock-main-data-for-analysis.dta
            ### ln_a_pg_pc: log per capita public good spending
            # NOTE: reconstructed ln_a_pg_pc = log(a_pg_pc)
            # a_pg_pc = a_pg / totpop
            # NOTE: created var a_pg = a_pg_pc * totpop
            # a_pg not personal
            "totpop": lambda cityyear: 1,
            
            ### Margin: winning margin
            #> from `Main-results.do` (run):
            # gen winner_share=ceda_votes/ceda_totvotes
            # gen loser_share=countervotes/ceda_totvotes
            # gen margin=winner_share-loser_share
            # gen relevant_margin=margin if relevantelectionyear==datayear
            # sort ENTITY_ID datayear
            # by ENTITY_ID: egen float Margin=max(relevant_margin)
            #>
            "ceda_totvotes": lambda cityyear: 1,
            "ceda_votes": lambda cityyear: 1,
            "countervotes": lambda cityyear: 1,

            #-- nonmodal-spend
            ### DD_nonmodal_wins: whether nonmodal candidate wins
            #> from `Main-results.do` (run):
            # gen DD_nonmodal_wins=nonmodal_wins  									//nonmodal_wins =1 if the winner is a non-modal candidate.
            # replace DD_nonmodal_wins=0 if DD_nonmodal_wins==1 & modalVnonmodal==0	//Only want to treat indicator to turn on if non-modal candidate wins a mVnm election
            # replace DD_nonmodal_wins=0 if datayear==2006							//2006 is the base year, so no one is treated. Set all obs equal to zero. 
            # sort ENTITY_ID datayear
            # replace DD_nonmodal_wins=1 if DD_nonmodal_wins[_n-1]==1 & ENTITY_ID==ENTITY_ID[_n-1] //Once treatment occurs, carry that forward.
            # replace DD_nonmodal_wins=0  if rel_order_mVnm<1 & modalVnonmodal!=. //Make sure all pre-relevant election observations are zero.
            #>
            # nonmodal_wins: whether eth of candidate matches modal eth of city
            # NOTE: reconstructed nonmodal_wins from share_pop_* and *_wins
            # *_wins not personal
            # share_pop_* = pop_* / totpop
            "nh_white": lambda cityyear: 1,
            "h": lambda cityyear: 1,
            "nh_black": lambda cityyear: 1,
            "nh_asian": lambda cityyear: 1,

            #-- segregation-effect, inequality-effect
            #> from Main-results.do (run):
            # foreach x in MGdis theil {
            # sum `x' if inmainsample==1, d
            # gen hi_`x'= `x'>r(p50) if `x'!=. & inmainsample==1
			# gen lo_`x'=1-hi_`x'
            # ...
            #>
            # MGdis: multi-group dissimiliarity index constructed from tract-level census data
            # NOTE: not enough info for DP
            # theil: theil index of inequality
            # NOTE: not enough info for DP
            ### treatXlow
            # gen treatXlow=DD_nonmodal_wins*lo_`x'
            ### treatXhigh
            # gen treatXhigh=DD_nonmodal_wins*hi_`x'
            ### high
            # gen high=hi_`x'

            # NOT USING — NOT ENOUGH INFO FOR DP
            #--- Gridlock-voting-data-for-analysis.dta
            ### voteshare
            # gen voteshare=ceda_votes/ceda_totvotes //vote share from each election.
            # ceda_votes, ceda_totvotes already noised
            ### DD_nonmodal_wins
            # NOTE: not enough info for DP; shares not provided in this file,
            # can't reconstruct
            ### Margin
            #> from `Main-results.do` (run):
            # gen winner_share=ceda_votes/ceda_totvotes
            # gen loser_share=countervotes/ceda_totvotes
            # gen margin=winner_share-loser_share
            # gen relevant_margin=margin if relevantelectionyear==datayear
            # sort ENTITY_ID datayear
            # by ENTITY_ID: egen float Margin=max(relevant_margin)
            #>
            # NOTE: not enough info for DP; countervotes not provided. wish they had included code for making this file.
            
            ### [not personal] numcandidates
            ### [not personal] year
            ### [not personal] haspre
            ### [not personal] datayear: year categorical

        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table3.csv")
        results.append(Result.from_esttab(
            id="nonmodal-spend",
            table=table,
            row="1.DD_nonmodal_wins",
            col="m3",
            expected_range=(None, 0)
        ))
        table = self._load_esttab(f"{self.path()}/results/table5.csv")
        for res, col in {
            "segregation": "T5_MGdis",
            "inequality": "T5_theil",
        }.items():
            treatXlow = Result.from_esttab(
                id="temp",
                table=table,
                row="1.treatXlow",
                col=col,
                expected_range=(0, None)
            )
            results.append(Result.from_esttab(
                id=f"{res}-effect",
                table=table,
                row="1.treatXhigh",
                col=col,
                expected_range=(None, treatXlow.est)
            ))
        # NOT USING — NOT ENOUGH INFO FOR DP
        # table = self._load_esttab(f"{self.path()}/results/table7.csv")
        # results.append(Result.from_esttab(
        #     id="nonmodal-outcome",
        #     table=table,
        #     row="1.DD_nonmodal_wins",
        #     col="voting_1",
        #     expected_range=(None, 0)
        # ))
        return results