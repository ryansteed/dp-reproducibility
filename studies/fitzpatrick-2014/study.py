from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Fitzpatrick(Study):
    id = 'fitzpatrick-2014'

    def data_paths(self) -> dict:
        return {
            "analysis-data": os.path.join(
                self.path(), "source/AEJ-Replication", "analysis-data.dta"
            ), # intermediate dataset not noised directly, but loading for validation
            "rcdata": os.path.join(
                self.path(), "source/AEJ-Replication", "rcdata.dta"
            ),
            # "dtaFile3": os.path.join(
            #     self.path(), "source/AEJ-Replication", "TSR89_01char.dta"
            # ),
            # "dtaFile4": os.path.join(
            #     self.path(), "source/AEJ-Replication", "TSR89_01char.dta"
            # )
            # ...
        }
    
    def _pre_processing(self, data):
        df = data["rcdata"]

        # deconstruct p*
        self._pvars = [
            "lep",
            "attd",
            "linc",
            "white",
            "black",
            "hisp",
            "asian"
        ]
        for v in self._pvars:
            df[v] = df[f"p{v}"] / 100 * df["enroll"]

        # reconstruct g*mt
        self._grades = [3, 6, 8]
        self._scores = ["mt", "rd"]
        for grade in self._grades:
            for score in self._scores:
                df[f"g{grade}{score}_sum"] = df[f"g{grade}{score}"] * df[f"g{grade}enrl"]
        
        data["rcdata"] = df
        return data
    
    def _post_processing(self, noised_data):
        df = noised_data["rcdata"]

        # reconstruct p*
        for v in self._pvars:
            df[f"p{v}"] = df[v] / df["enroll"] * 100
        
        # reconstruct g*mt
        for grade in self._grades:
            for score in self._scores:
                df[f"g{grade}{score}"] = np.where(
                    (df[f"g{grade}enrl"] == 0) | df[f"g{grade}enrl"].isna(),
                    df[f"g{grade}{score}"],
                    df[f"g{grade}{score}_sum"] / df[f"g{grade}enrl"]
                )

        noised_data["rcdata"] = df
        return noised_data
    
    def vars_to_noise(self) -> list:
        return {
            "post_replication": [
                "post_above",
                "post_tottchr",
                "enrollsq",
                "avgenroll",
                "mathscore",
                "rdscore",
                "preread",
                "enroll",
                "plep",
                "pattd",
                "plinc",
                "pblack",
                "phisp",
                "pasian",
                "pwhite",
            ]
        }
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `Main-Results-Tables.do`: ###
        # use analysis-data
        # ...
        #--- teacheryear-math
        # eststo m1: xi: xtreg mathscore post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1997 [aw=avgenroll], fe vce(robust)
        #--- teacheryear-read
        # eststo m2: xi: xtreg rdscore post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1997 [aw=avgenroll], fe vce(robust)
        # ...
        #--- teacheryear-read_lowincome
        # eststo lowincome: xi: xtreg rdscore post_above post_tottchr pblack phisp pasian plep pattd enroll enrollsq i.year*i.grade if year<=1997 & plinc>=$lowinc [aw=avgenroll], fe vce(robust)
        #--- teacheryear-read_lowwhite
        # eststo lowwhite: xi: xtreg rdscore post_above post_tottchr plinc plep pattd enroll enrollsq i.year*i.grade if year<=1997 & pwhite<$lowwhite [aw=avgenroll], fe vce(robust)
        #--- teacheryear-read_lowbaseline
        # eststo lowbaseline: xi: xtreg rdscore post_above post_tottchr plinc pblack phisp pasian plep pattd enroll enrollsq i.year*i.grade if year<=1997 & preread<$lowread [aw=avgenroll], fe vce(robust)
        ###
        sensitivities = {
            ### post_above
            #> from Main-Results-Tables.do (run):
            # gen tot_above=tot_above_gr3 if grade==3
            # replace tot_above=tot_above_gr6 if grade==6
            # replace tot_above=tot_above_gr8 if grade==8
            # ...
            # gen post_above=post*tot_above
            #>
            # post: time dummy
            # tot_above: avg teachers with >= 15 years of experience over years pre
            # built from teacher-level data TSR89_01char in Data_Setup.do (not run)
            #> from Data_Setup.do (NOT run):
            # gen temp=exp_gr3 if year<=1993
            # gen abovegr3=teach_3 if temp>=15 & temp~=.
            # replace abovegr3=0 if abovegr3==. & temp~=. 
            # replace abovegr3=. if year>1993
            # drop temp
            # egen temp=sum(abovegr3), by(rcds_fix year)
            # replace temp=. if year>1993
            # egen tot_above_gr3 = mean(temp), by(rcds_fix)
            #>
            # so tot_above_gr* = average(abovegr3) for each year
            # one teacher could change this average by at most num_years / num_years = 1
            "tot_above_gr3": lambda rdcsyear: 1,
            "tot_above_gr6": lambda rdcsyear: 1,
            "tot_above_gr8": lambda rdcsyear: 1,

            ### post_tottchr: post x total teachers averaged over all years
            #> from Main-Results-Tables.do (run):
            # gen tot_tchr=tot_gr3 if grade==3
            # replace tot_tchr=tot_gr6 if grade==6
            # replace tot_tchr=tot_gr8 if grade==8
            # ...
            # gen post_tottchr=post*tot_tchr
            #>
            # same as above, tot_gr3 is the average gr3 teachers over all years in each rcds
            "tot_gr3": lambda rdcsyear: 1,
            "tot_gr6": lambda rdcsyear: 1,
            "tot_gr8": lambda rdcsyear: 1,

            ### enroll: enrollment
            # NOT an average; from `rcdata`, already rcds-year level
            "enroll": {
                "sensitivity": lambda rdcsyear: 1,
                "lb": 1
            },

            ### enrollsq
            #> from Main-Results-Tables.do (run):
            # gen enrollsq=enroll*enroll
            #>
            # enroll already noised

            ### avgenroll: average enrollment over years pre
            #> from Main-Results-Tables.do (run):
            # gen tempenroll=enroll if year<=1993
            # egen avgenroll=mean(tempenroll), by(clusterid)
            #>
            # enroll already noised

            ### p* variables
            # assuming enroll is denom; comes from same dataset
            # p* = * / enroll x 100
            # enroll already noised
            # NOTE: created var * = p* / 100 x enroll
            ## plep: % limited English proficient
            "lep": lambda rdcsyear: 1,
            ## pattd: attendance rate
            # assuming this is the average attendance rate over all students and all days of the year;
            # a student could be absent every day at worst, which would lower time average by 1
            "attd": lambda rdcsyear: 1,
            ## plinc: % low income
            "linc": lambda rdcsyear: 1,
            
            #--- teacheryear-math, teacheryear-read, teacheryear-read_lowincome
            ## pblack: % black students
            "black": lambda rdcsyear: 1,
            ## phisp: % hispanic students
            "hisp": lambda rdcsyear: 1,
            ## pasian: % asian students
            "asian": lambda rdcsyear: 1,

            #--- teacheryear-read_lowwhite
            ## pwhite: % white students
            "white": lambda rdcsyear: 1,

            #--- teacheryear-math
            ### mathscore
            #> from Main-Results-Tables.do (run):
            # gen mathscore=g3mtstd if grade==3
            # replace mathscore=g6mtstd if grade==6
            # replace mathscore=g8mtstd if grade==8
            #>
            #> from Data_Setup_abbrv.do (run):
            # gen g3mtstd=.
            # forval x=1990(1)2000{
            # summ g3mt if year==`x'
            # local mean=r(mean)
            # local sd=r(sd)
            # replace g3mtstd=(g3mt-`mean')/`sd' if year==`x'
            # }
            #>
            # g*mt: average math score in rcds-year
            # g*mt = g*mt_sum / g*enrl
            # NOTE: created var g*mt_sum = g*mt x g*enrl
            # NOTE: assuming exams are scored out of 600 (not clear)
            "g3mt": lambda rdcsyear: 600,
            "g6mt": lambda rdcsyear: 600,
            "g8mt": lambda rdcsyear: 600,

            #--- teacheryear-read, teacheryear-read_lowincome, teacheryear-read_lowwhite, teacheryear-read_lowbaseline
            ### rdscore
            #> from Main-Results-Tables.do (run):
            # gen rdscore=g3rdstd if grade==3
            # replace rdscore=g6rdstd if grade==6
            # replace rdscore=g8rdstd if grade==8
            #>
            # same as above, but for reading scores
            # NOTE: created var g*rd_sum = g*rd x g*enrl
            # NOTE: assuming exams are scored out of 600 (not clear)
            "g3rd": lambda rdcsyear: 600,
            "g6rd": lambda rdcsyear: 600,
            "g8rd": lambda rdcsyear: 600,

            #--- teacheryear-read_lowbaseline
            ### preread
            #> from Main-Results-Tables.do (run):
            # gen temp=rdscore if year<=1993
            # egen preread=mean(rdscore), by(rcds_fix grade)
            # drop temp
            #>
            # rdscore already noised

        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        # table = self._load_esttab(f"{self.path()}/results/table1.csv")
        # results.append(Result.from_esttab(
        #     id="teacheryear-number",
        #     table=table,
        #     row="post_above",
        #     col="est1",
        #     expected_range=(0, None)
        # ))
        table = self._load_esttab(f"{self.path()}/results/table2.csv")
        results.append(Result.from_esttab(
            id="teacheryear-math",
            table=table,
            row="post_above",
            col="m1",
            expected_range=(0, 0)
        ))
        results.append(Result.from_esttab(
            id="teacheryear-read",
            table=table,
            row="post_above",
            col="m2",
            expected_range=(0, None)
        ))

        table7 = self._load_esttab(f"{self.path()}/results/table7.csv")
        for subset, columns in {
            "lowincome": {
                "treatment": "lowincome",
                "control": "lowincomecontrol",
            },
            "lowwhite": {
                "treatment": "lowwhite",
                "control": "lowwhitecontrol",
            },
            "lowbaseline": {
                "treatment": "lowbaseline",
                "control": "lowbaselinecontrol",
            }
        }.items():
            control = Result.from_esttab(
                id="teacheryear-read_control",
                table=table7,
                row="post_above",
                col=columns["control"],
                expected_range=None
            )
            results.append(Result.from_esttab(
                id=f"teacheryear-read_{subset}",
                table=table7,
                row="post_above",
                col=columns["treatment"],
                expected_range=(control.est, None) # should be greater than control
            ))

        return results