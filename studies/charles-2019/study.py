from simulate_privacy.studies import Study, Result
import pandas as pd


class Charles(Study):
    id = 'charles-2019'

    def data_paths(self):
        return {
            "voting_paper_extract_public": f"{self.path()}/source/data/voting_paper_extract_public.dta"
        }
    
    def vars_to_noise(self) -> list:
        return [
            "gov_d_gov_turnout",
            "pres_d_pres_turnout",
            "sen6_d_senate_turnout",
            "congr4_d_congr_turnout",
            "st4_d_sthouse_turnout",
            "gov_d_lper_earn",
            "pres_d_lper_earn",
            "sen6_d_lper_earn",
            "congr4_d_lper_earn",
            "st4_d_lper_earn",
            "gov_d_lper_emp",
            "pres_d_lper_emp",
            "sen6_d_lper_emp",
            "congr4_d_lper_emp",
            "st4_d_lper_emp",
            "shfemale",
            "shblack",
            "shothrace",
            "sh30s",
            "sh40s",
            "sh50s",
            "sh60s",
            "sh7080s"
        ]
    
    def other_vars(self) -> list:
        return [
            "coalstate",
            "oilstate",
            "cpi",
            "oilprice",
            "gasprice"
        ]
    
    def time_index(self):
        #[prep_aej_public.do] xtset fips year
        return "year"
    
    def subset_index(self):
        #[prep_aej_public.do] xtset fips year
        return "fips"

    def sensitivity_matrix(self) -> dict:
        ### regression code from table4_aej.do, table5_aej.do:
        # Table 4
        # // 2SLS
        # foreach i in "earn" "emp" {
            # ...
            # eststo: ivregress 2sls gov_d_gov_turnout ///
            #     stateyrv* gov_d_lpop gov_d_sh* (gov_d_lper_`i'=gov_d_*1974_empiv) ///
            #     if sampleGov==1 [aw=nadults], cluster(fipsst)
            # ...
            # eststo: ivregress 2sls pres_d_pres_turnout ///
            #     stateyrv* pres_d_lpop pres_d_sh* (pres_d_lper_`i'=pres_d_*1974_empiv) ///
            #     if samplePres==1 [aw=nadults], cluster(fipsst)
            # ...
            # eststo: ivregress 2sls sen6_d_senate_turnout ///
            #     stateyrv* sen6_d_lpop sen6_d_sh* (sen6_d_lper_`i'=sen6_d*1974_empiv) ///
            #     if sampleSen==1 [aw=nadults], cluster(fipsst)
            # ...
        # }
        # Table 5
        # foreach j in "earn" "emp" {
        #     ...
        #     eststo: ivreg2 congr4_d_congr_turnout ///
        #         stateyrv* congr4_d_lpop congr4_d_sh* (congr4_d_lper_`j'=congr4_d*1974_empiv) ///
        #         if sampleC==1 [aw=nadults], first cluster(fipsst)
        #     ...
        # }
        # foreach i in "earn" "emp" {
        #     ...
        #     // coal/oil FD 2SLS
        #     tab stateyr if sampleSt3==1, gen(stateyrv)
        #     eststo: ivregress 2sls st4_d_sthouse_turnout ///
        #         stateyrv* st4_d_lpop st4_d_sh* (st4_d_lper_`i'=st4_d*og_1974_empiv) ///
        #         if sampleSt3==1 [aw=nadults], cluster(fipsst)
        #     ...
        # }
        ###
        vars_to_noise = {
            ### *_turnout = *_total / nadults ###
            # from prep_aej_public.do,
            # turnout = number of votes cast / census estimate of number of individuals age 20 and over
            # in the source, the # adults is `nadults`
            "nadults": {
                "sensitivity": lambda cnty: 1,
                "lb": 0 # some regs weight by num adults
            },
            ## - gov_d_gov_turnout
            "gov_total": lambda cnty: 1,
            ## - pres_d_pres_turnout
            "pres_total": lambda cnty: 1,
            ## - sen6_d_senate_turnout
            "senate_total": lambda cnty: 1,
            ## - congr4_d_congr_turnout
            "congr_total": lambda cnty: 1,
            ## - st4_d_sthouse_turnout
            "state_house_total": lambda cnty: 1,

            ### lper_earn = log(earn / pop) ###
            # computed in prep_aej_public.do
            ## - gov_d_lper_earn
            ## - pres_d_lper_earn
            ## - sen6_d_lper_earn
            ## - congr4_d_lper_earn
            ## - st4_d_lper_earn
            "pop": lambda cnty: 1,
            # earn = total earnings in the county
            # no max salary provided, so let's use a moderate baseline
            # assuming no top coding
            # NOTE ASSUMPTION: max earnings 500000
            "earn": lambda cnty: 500000,

            ### lper_emp = log(emp / nadults) ###
            # computed in prep_aej_public.do
            ## - gov_d_lper_emp
            ## - pres_d_lper_emp
            ## - sen6_d_lper_emp
            ## - congr4_d_lper_emp
            ## - st4_d_lper_emp
            "emp": lambda cnty: 1,

            ### controls ### 
            ## - shfemale
            # gen shfemale	= numfemale_adults/nadults
            "numfemale_adults": lambda cnty: 1,
            ## - shblack
            # gen shblack	= numblack_adults/nadults
            "numblack_adults": lambda cnty: 1,
            ## - shothrace
            # gen shothrace	= numothrace_adults/nadults
            "numothrace_adults": lambda cnty: 1,
            ## - sh30s
            # gen sh30s	= num30s/nadults
            "num30s": lambda cnty: 1,
            ## - sh40s
            # gen sh40s	= num40s/nadults
            "num40s": lambda cnty: 1,
            ## - sh50s
            # gen sh50s	= num50s/nadults
            "num50s": lambda cnty: 1,
            ## - sh60s
            # gen sh60s	= num60s/nadults
            "num60s": lambda cnty: 1,
            ## - sh7080s
            # gen sh7080s	= num7080s/nadults
            "num7080s": lambda cnty: 1
        }
        return vars_to_noise

    def extract_results(self) -> list[Result]:
        results = []

        table4 = self._load_esttab(f"{self.path()}/results/table4.csv")
        results.append(Result.from_esttab(
            id="gov_d_lper_earn-turnout",
            table=table4,
            row="gov_d_lper_earn",
            col="est2",
            expected_range=(None, 0)  # should be negative, significant
        ))
        results.append(Result.from_esttab(
            id="gov_d_lper_emp-turnout",
            table=table4,
            row="gov_d_lper_emp",
            col="est4",
            expected_range = (None, 0)  # should be negative, significant
        ))
        results.append(Result.from_esttab(
            id="pres_d_lper_earn-turnout",
            table=table4,
            row="pres_d_lper_earn",
            col="est6",
            expected_range = (0, 0)  # should be insignificant
        ))
        results.append(Result.from_esttab(
            id="pres_d_lper_emp-turnout",
            table=table4,
            row="pres_d_lper_emp",
            col="est8",
            expected_range = (0, 0)  # should be insignificant
        ))
        results.append(Result.from_esttab(
            id="sen6_d_lper_earn-turnout",
            table=table4,
            row="sen6_d_lper_earn",
            col="est10",
            expected_range = (None, 0)  # should be negative, significant
        ))
        results.append(Result.from_esttab(
            id="sen6_d_lper_emp-turnout",
            table=table4,
            row="sen6_d_lper_emp",
            col="est12",
            expected_range = (None, 0)  # should be negative, significant
        ))

        table5 = self._load_esttab(f"{self.path()}/results/table5.csv")
        results.append(Result.from_esttab(
            id="congr4_d_lper_earn-turnout",
            table=table5,
            row="congr4_d_lper_earn",
            col="est6",
            expected_range = (None, 0)  # should be negative, significant
        ))
        results.append(Result.from_esttab(
            id="congr4_d_lper_emp-turnout",
            table=table5,
            row="congr4_d_lper_emp",
            col="est8",
            expected_range = (None, 0)  # should be negative, significant
        ))
        results.append(Result.from_esttab(
            id="st4_d_lper_earn-turnout",
            table=table5,
            row="st4_d_lper_earn",
            col="est12",
            expected_range = (None, 0)  # should be negative, significant
        ))
        results.append(Result.from_esttab(
            id="st4_d_lper_emp-turnout",
            table=table5,
            row="st4_d_lper_emp",
            col="est16",
            expected_range = (None, 0)  # should be negative, significant
        ))

        return results
