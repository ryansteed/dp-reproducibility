from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Snow(Study):
    id = 'snow-2019'

    def data_paths(self) -> dict:
        return {
            "nhgist60": os.path.join(
                self.path(), "source","MS20080918_data_programs","data","cenpan","nhgist60.dta"
            ),
            "tracts60": os.path.join(
                self.path(), "source","MS20080918_data_programs","data","cenpan","tracts60.dta"
            )
        }
    
    def vars_to_noise(self):
        # list all personal vars used in the regression
        return {
            "post_replication": [
                "lnwpu",
                "lnbpu"
            ]
        }
    
    def _pre_processing(self, data):
        return data
    
    def _post_processing(self, noised_data):
        return noised_data
    
    def time_index(self):
        return "year"
    
    def subset_index(self):
        return "msa"
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `panel-censusx.do`: ###
        # *** A set of tracts in Tampa, FL have incorrect data from NHGIS -- use alternate source
        # use ../data/cenpan/tracts60.dta
        # ...
        # use ../data/cenpan/nhgist60.dta
        # ...
        # gen pop59w = wm59+wf59
        # gen pop1014w = wm1014+wf1014
        # ...
        # gen pop59b = om59+of59
        # gen pop1014b = om1014+of1014
        # ...
        # gen pop59t = pop59w+pop59b
        # gen pop1014t = pop1014w+pop1014b
        # ...
        # replace pop59b = pop59b*(black/(black+other)) 
        # replace pop1014b = pop1014b*(black/(black+other)) 
        # ...
        # ** Rename and rescale school attendance variables
        # rename publicelem publicelemt
        # gen publicelemb = publicelemt*(pop59b+pop1014b)/(pop59t+pop1014t)
        # gen publicelemw = publicelemt*(pop59w+pop1014w)/(pop59t+pop1014t)
        # ...
        # rename publichs publichst
        # gen publichsb = publichst*(pop1519b)/(pop1519t)
        # gen publichsw = publichst*(pop1519w)/(pop1519t)
        ###
        ### relevant regression code from `tables2to6.do`: ###
        # local data = "../data/dis70panx.dta";
        # use `data', clear;
        # ...
        # replace publicelemhsw = publicelemw + publichsw if year ~= 1990;
        # replace publicelemhsb = publicelemb + publichsb if year ~= 1990;
        # replace publicelemhst = publicelemt + publichst if year ~= 1990;
        # replace privatelemhsw = privatelemw + privatehsw if year ~= 1990;
        # replace privatelemhsb = privatelemb + privatehsb if year ~= 1990;
        # replace privatelemhst = privatelemt + privatehst if year ~= 1990;
        # # ...
        # gen lnwpu = ln(publicelemhsw);
        # gen lnbpu = ln(publicelemhsb);
        # gen lnwpr = ln(privatelemhsw); # NOT USED IN SELECTED REGS
        # gen lnbpr = ln(privatelemhsb); # NOT USED IN SELECTED REGS
        # gen lnwto = ln(white); # NOT USED IN SELECTED REGS
        # gen lnbto = ln(black); # NOT USED IN SELECTED REGS
        # ...
        ## white_post
        # [when `r` is `pu`:]
        # eststo: xi: xtreg lnw`r' imp_post imp_pre23  i.year*i.south   		, fe i(leaid) cluster(leaid);
        # ...
        ## white_south_post
        # [when `r` is `pu`:]
        # eststo: xi: xtreg lnw`r' imp_post_south impost_4_south imp_post_nonsouth impost_4_nonsouth 
		# 				   i.year*i.south		, fe i(leaid) cluster(leaid);
        # ...
        ## black_post
        # [when `r` is `pu`:]
        # eststo: xi: xtreg lnb`r' impost_4            i.year*i.south , fe i(leaid) cluster(leaid);
        # ...
        ## black_nonsouth_post
        # [when `r` is `pu`:]
        # eststo: xi: xtreg lnb`r' impost_4_south impost_4_nonsouth i.year*i.south i.leaid*year  , fe i(leaid) cluster(leaid);
        sensitivities = {
            ### lnwpu: log of white public enrollment
            # gen lnwpu = ln(publicelemhsw);
            # publicelemhsw: white public enrollment
            # replace publicelemhsw = publicelemw + publichsw if year ~= 1990;
            #> from `panel-censusx.do`:
            # rename publicelem publicelemt
            # gen publicelemw = publicelemt*(pop59w+pop1014w)/(pop59t+pop1014t)
            # rename publichs publichst
            # gen publichsw = publichst*(pop1519w)/(pop1519t)
            #>
            ## publicelem: total public elementary enrollment
            "publicelem": lambda msa: 1,
            ## publichs: total public high school enrollment
            "publichs": lambda msa: 1,
            ## pop59w
            # gen pop59w = wm59+wf59
            # wm59: White, 5-9 Years, Male
            "wm59": lambda msa: 1,
            # wf59: White, 5-9 Years, Female
            "wf59": lambda msa: 1,
            ## pop1014w
            # gen pop1014w = wm1014+wf1014
            # wm1014: White, 10-14 Years, Male
            "wm1014": lambda msa: 1,
            # wf1014: White, 10-14 Years, Female
            "wf1014": lambda msa: 1,
            ## pop59t
            # gen pop59t = pop59w+pop59b
            # pop59w already noised above
            # pop59b already noised below
            ## pop1014t
            # gen pop1014t = pop1014w+pop1014b
            # pop1014w already noised above
            # pop1014b already noised below
            ## pop1519w
            # gen pop1519w = wm1519+wf1519
            # wm1519: White, 15-19 Years, Male
            "wm1519": lambda msa: 1,
            # wf1519: White, 15-19 Years, Female
            "wf1519": lambda msa: 1,
            ## pop1519t
            # gen pop1519t = pop1519w+pop1519b
            # pop1519w already noised above
            # pop1519b already noised below
            

            ### lnbpu: log of black public enrollment
            # gen lnbpu = ln(publicelemhsb);
            # publicelemhsb: black public enrollment
            # replace publicelemhsb = publicelemb + publichsb if year ~= 1990;
            #> from `panel-censusx.do`:
            # rename publicelem publicelemt
            # gen publicelemb = publicelemt*(pop59b+pop1014b)/(pop59t+pop1014t)
            # rename publichs publichst
            # gen publichsb = publichst*(pop1519b)/(pop1519t)
            #>
            ## publicelem: already noised above
            ## publichs: already noised above
            ## pop59b
            # gen pop59b = om59+of59
            # replace pop59b = pop59b*(black/(black+other))
            # om59: Non-white, 5-9 Years, Male
            "om59": lambda msa: 1,
            # of59: Non-white, 5-9 Years, Female
            "of59": lambda msa: 1,
            # black: total black population
            "black": lambda msa: 1,
            # other: total other population
            "other": lambda msa: 1,
            ## pop1014b
            # gen pop1014b = om1014+of1014
            # replace pop1014b = pop1014b*(black/(black+other)) 
            # om1014: Non-white, 10-14 Years, Male
            "om1014": lambda msa: 1,
            # of1014: Non-white, 10-14 Years, Female
            "of1014": lambda msa: 1,
            # black: already noised above
            # other: already noised above
            ## pop59t: already noised above
            ## pop1014t: already noised above
            ## pop1519b
            # gen pop1519b = om1519+of1519
            # replace pop1519b = pop1519b*(black/(black+other)) 
            # om1519: Non-white, 15-19 Years, Male
            "om1519": lambda msa: 1,
            # of1519: Non-white, 15-19 Years, Female
            "of1519": lambda msa: 1,
            # black: already noised above
            # other: already noised above
            # pop1519t: already noised above
            ## pop1519t: already noised above


            ### NOT USED
            ### privatelemhsw: white private enrollment
            # "privatelemhsw": lambda msa: 1,
            # ### privatelemhsb: (black private enrollment
            # "privatelemhsb": lambda msa: 1,
            # ### white: total white population
            # "white": lambda msa: 1,
            # ### black: total black population
            # "black": lambda msa: 1,


            #* ADDED BY RYAN *#
            ### [not private] imp_post: whether year is after implementation
            # gen imp_post = (year >= imp);
            ### [not private] imp_pre23: year is within 2 years before implementation
            # gen imp_pre23   = (year < imp & year>=imp-2);
            ### [not private] year: year
            ### [not private] south: dummy for south
            ### [not private] leaid: lea id, geographic unit
            ### [not private] imp_post_south: imp_post * south
            # for var  `varlist' : gen imp_post_X = imp_post*X;
            ### [not private] impost_4: whether year is 4 years after implementation
            # gen impost_4    = (year >=  imp + 4);
            ### [not private] impost_4_south: impost_4 * south
            # for var  `varlist' : gen impost_4_X = impost_4*X;
            ### [not private] imp_post_nonsouth: imp_post * (south==0)
            # for var  `varlist' : gen imp_post_X = imp_post*X;
            ### [not private] impost_4_nonsouth: impost_4 * (south==0)
            # for var  `varlist' : gen impost_4_X = impost_4*X;
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="white_post",
            table=table,
            row="imp_post",
            col="pu1",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="white_south_post",
            table=table,
            row="imp_post_south",
            col="pu2",
            expected_range=(None, 0)
        ))
        table2 = self._load_esttab(f"{self.path()}/results/table2.csv")
        results.append(Result.from_esttab(
            id="black_post",
            table=table2,
            row="impost_4",
            col="pu3",
            expected_range=(0, None)
        ))
        results.append(Result.from_esttab(
            id="black_nonsouth_post",
            table=table2,
            row="impost_4_nonsouth",
            col="pu4",
            expected_range=(0, None)
        ))
        return results