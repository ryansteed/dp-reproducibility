from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import os


class Buonanno(Study):
    id = 'buonanno-2013'

    def data_paths(self) -> dict:
        return {
            "prisonertimeseries2": os.path.join(
                self.path(), "source", "20111641_data","prisonertimeseries2.dta"
            ),
            "monthnational0408": os.path.join(
                self.path(), "source", "20111641_data","monthnational0408.dta"
            ),
            "pardonsbyprovince": os.path.join(
                self.path(), "source", "20111641_data","pardonsbyprovince.dta"
            ),
            "population.dta": os.path.join(
                self.path(), "source", "20111641_data","population.dta"
            ),
            "monthly_data_0408": os.path.join(
                self.path(), "source", "20111641_data","monthly_data_0408.dta"
            ),
            "regionnational": os.path.join(
                self.path(), "source", "20111641_data","regionnational.dta"
            )
            # ...
        }
    
    def _post_processing(self, noised_data):
        for name in noised_data.keys():
            df = noised_data[name]
            # reconstructing incrate
            if name == "prisonertimeseries2":
                df["incrate"] = df["prisoners"] / df["population"] * 100000
            if name == "regionnational":
                df["incrate"] = df["prisoner_jail"] / df["population"] * 100000
            noised_data[name] = df
        return noised_data
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `table2andinputefortables3_4and.do`: ###
        # use monthnational0408
        # sort ymonthrelative
        # merge ymonthrelative using prisonertimeseries2
        # sort crecode ymonthrelative
        # ...
        # local crimes "12 1 2 3 4 5 6 7 8 9 10 11"
        # ...
        # foreach val of local crimes {
        # ...
        # eststo: xi: arima  crime2 ymonthrelative ymonthrelative2 post postymonth postymonth2 i.month i.year if crecode==`val', ar(1)
        ###

        ### relevant regression code from `figure1andpanelboftable2.do`: ###
        # use prisonertimeseries2
        # ...
        # eststo: xi: arima  incrate ymonthrelative ymonthrelative2 post postmonth postmonth2 i.month i.year, ar(1)
        ###

        ### relevant regression code from `table7and8.do`: ###
        # local crimes "1 2 3 4 5 6 7 8 9 10 11 12"
        # foreach val of local crimes {
        # keep if crecode==`val'
        # use regionnational
        # ...
        #-- parson_diffincrime
        # eststo: reg cdiff2 pardonrate [aweight=population]
        # ...
        #-- parson_reverseinca
        # use regionnational
        # keep if crecode==12
        # ...
        # gen cdiff2= crate-l.crate
        # gen pardonincrate=pardonrate*l.incrate
        # ...
        # eststo: reg cdiff2 pardonrate pardonincrate l.incrate l.crate [aweight=population]
        ###
        vars_to_noise = {
            ### population
            # for tables7and8.do, regionnational:
            # merge idprov year using population
            "population": lambda provincemonth: 1,

            #-- monthnational0408
            
            ### crime2: total monthly crimes per 100,000 residents
            # from `table1figure2.do`:
            # use monthly_data_0408.dta
            # ...
            # /*collapse to nation-month level*/
            # sort year month crecode
            # collapse (sum) crime_number, by(year month crecode)
            # /*setting annual national population by year*/
            # gen pop=.
            # replace pop=58462375 if year==2004
            # replace pop=58751711 if year==2005
            # replace pop=58691139 if year==2006
            # replace pop=59175633 if year==2007
            # replace pop=59832200 if year==2008
            # /*generating crime rate and year/month variable*/
            # gen crime2=crime_number/pop*100000
            # crime_number: (sum) crime_number
            "crime_number": lambda provincemonth: 1,
            # NOTE: pop must be left invariant, hard-coded

            #-- prisonertimeseries2
            
            ### incrate: monthly incarceration rate
            # for prisonertimeseries2:
            # NOTE: reconstructed incrate = prisoners / population
            # population already noised
            # for prisonertimeseries2
            "prisoners": lambda provincemonth: 1,

            #-- regionnational
            ### crate: crime rate per 100,000
            # from tables7and8.do:
            # gen crate=crime_number/population*100000
            # crime_number, population already noised

            ### cdiff2: change in crime rate
            # cdiff2 = crate - l2.crate
            # crate already noised

            ### pardonrate: pardons per 100000
            # from tables7and8.do:
            # merge idprov using pardonsbyprovince
            # ...
            # gen pardonrate=pardoned/population*100000
            # population already noised
            "pardoned": lambda provincemonth: 1,

            ### incrate: see above
            # for table7and8.do, regionnational:
            # gen incrate=prisoner_jail/population*100000
            # population already noised
            "prisoner_jail": lambda provincemonth: 1,

            ### pardonincrate: pardons * l.incrate
            # gen pardonincrate=pardonrate*l.incrate
            # pardonrate, incrate already noised

            ### [not personal] month

            ### [not personal] year

            ### [not personal] ymonthrelative

            ### [not personal] ymonthrelative2

            ### [not personal] post
            # gen post=ymonthrelative>0

            ### [not personal] postmonth

            ### [not personal] postmonth2

            ### [not personal] postymonth
            # gen postymonth=post*ymonthrelative

            ### [not personal] postymonth2
            # gen postymonth2=post*ymonthrelative2
        }
        return vars_to_noise
    
    def vars_to_noise(self):
        return {
            "pre_replication": [
                "population",
                "incrate"
            ],
            "post_replication": [
                "crime2",
                "crate",
                "cdiff2",
                "pardonrate",
                "pardonincrate"
            ]
        }

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table2a.csv")
        results.append(Result.from_esttab(
            id="pardon_crime",
            table=table,
            row="post",
            col="est4",
            expected_range=(0, None)
        ))
        table = self._load_esttab(f"{self.path()}/results/table2b.csv")
        results.append(Result.from_esttab(
            id="pardon_incarceration",
            table=table,
            row="post",
            col="est1",
            expected_range=(None, 0)
        ))
        table = self._load_esttab(f"{self.path()}/results/table6.csv")
        results.append(Result.from_esttab(
            id="parson_diffincrime",
            table=table,
            row="pardonrate",
            col="est1",
            expected_range=(0, None)
        ))
        table = self._load_esttab(f"{self.path()}/results/table7.csv")
        results.append(Result.from_esttab(
            id="parson_reverseinca",
            table=table,
            row="pardonrate",
            col="est1",
            expected_range=(0, None)
        ))
        return results 