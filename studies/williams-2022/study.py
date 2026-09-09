from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import os


class Williams(Study):
    id = 'williams-2022'

    def data_paths(self) -> dict:
        return {
            # "maindata": os.path.join(
            #     self.path(), "source", "Williams_files", "Analysis_data", "maindata.dta"
            # ),
            "SEER_POP": os.path.join(
                self.path(), "source", "Williams_files", "Input_data", "SEER_POP.dta"
            ),
            "SOS": os.path.join(
                self.path(), "source", "Williams_files", "Input_data", "SOS.dta"
            ),
            "lynchcorrectblacksnomob": os.path.join(
                self.path(), "source", "Williams_files", "Analysis_data", "lynchcorrectblacksnomob.dta"
            ),
            "POP_1900_NHGIS": os.path.join(
                self.path(), "source", "Williams_files", "Analysis_data", "POP_1900_NHGIS.dta"
            ),
            "illiterate_NHGIS": os.path.join(
                self.path(), "source", "Williams_files", "Analysis_data", "illiterate_NHGIS.dta"
            ),
            "incarceration_2010": os.path.join(
                self.path(), "source", "Williams_files", "Input_data", "incarceration_2010.dta"
            ),
            "totalpollscounty": os.path.join(
                self.path(), "source", "Williams_files", "Input_data", "totalpollscounty.dta"
            ),
            "censusage": os.path.join(
                self.path(), "source", "Williams_files", "Analysis_data", "censusage.dta"
            ),
            "earnings_QWI": os.path.join(
                self.path(), "source", "Williams_files", "Input_data", "earnings_QWI.dta"
            ),
            "maritalcensus_temp": os.path.join(
                self.path(), "source", "Williams_files", "Input_data", "maritalcensus_temp.dta"
            ),
            "POP_2010_temp": os.path.join(
                self.path(), "source", "Williams_files", "Input_data", "POP_2010_temp.dta"
            ),
        }
    
    def vars_to_noise(self) -> list:
        return [
            "Blackrate_regvoters",
            "Whiterate_regvoters",
            # "incarceration_2010", # could not noise
            "pollscapita",
            "Black_beyondhs",
            # "Black_avgage", # could not noise
            # "Black_Earnings", # could not noise
            "share_maritalblacks",
            "lynchcapitamob",
            "lynchcapitawhite",
            "Black_share_illiterate"
        ]
    
    def sensitivity_matrix(self, year_cutoff: int = 1950) -> pd.DataFrame:
        ### relevant regression code from `Maindo.do`: ###
        # global ylist_black Blackrate_regvoters;
        # global ylist_white Whiterate_regvoters;
        # global historical c.Black_share_illiterate c.initial c.newscapita c.farmvalue c.sfarmprop1860 c.landineq1860 c.fbprop1860;
        # global cont_black c.Black_beyondhs c.Black_avgage c.Black_Earnings c.share_maritalblacks;
        # ...
        # ** Table 2: Falsification exercises;
        # regress $ylist_black lynchcapitamob $historical i.State_FIPS; 
        # estimates store b1;
        # ...
        # regress $ylist_white lynchcapitawhite $historical i.State_FIPS;
        # estimates store w2;

        # ...

        # ** Table 5: Black registration and lynching rate with comtemporary controls;
        # ...
        # regress $ylist_black lynchcapitamob c.incarceration_2010 c.pollscapita $historical $cont_black i.State_FIPS; 
        # estimates store t5;
        ###
        vars_to_noise = {
            ### registration rates
            # relevant code from Createmain.do:
            # use "$infile/SOS";
            # merge m:1 County State Election using "$infile/SEER_POP";
            ## Blackrate_regvoters
            # Black_POP is from the `SEER_POP` file
            # generate Blackrate_regvoters = register_black/Black_POP*100;
            "Black_POP": lambda county: 1,
            # register_black is from the `SOS` file
            "register_black": lambda county: 1,
            ## Whiterate_regvoters
            # relevant code from Createmain.do: 
            # generate Whiterate_regvoters = register_white/White_POP*100;
            "White_POP": lambda county: 1,
            "register_white": lambda county: 1,
            ###

            ## c.initial - year county was formed, NOT PERSONAL DATA

            ## c.farmvalue - NOT PERSONAL DATA, average farm value
            
            ## c.incarceration_2010: incarceration rate of blacks per 10k pop
            # NOTE: comes directly from source, not computed by author
            # ASSUMPTION: 2010 population is known
            # merge m:1 fips using "$infile/incarceration_2010";
            # NOTE: can't do this one, black pop doesn't exist in this file
            # "incarceration_2010": lambda county: 1 / county["Black_POP_2010"],

            ## c.pollscapita
            # merge m:1 fips using "$infile/totalpollscounty";
            # generate pollscapita = (polls/Total_POP_2010)*10000;
            # relevant regression code from POP_2010.do:
            # use "$infile/POP_2010_temp";
            # ...
            # rename h7x002 White_POP_2010; 
            # rename h7x003 Black_POP_2010;
            "h7x002": lambda county: 1,
            "h7x003": lambda county: 1,
            "polls": lambda county: 1,

            ## c.Black_beyondhs: proportion with some college
            # relevant code from Censuseducation.do:
            # use "$infile/censuseducation_temp";
            # generate Black_beyondhs = (grw018 + grw019 + grw020 + grw021 + grw025 + grw026 + grw027 + grw028)/(grw015 + grw016 + grw017 + grw018 + grw019 + grw020 + grw021 + grw022 + grw023 + grw024 + grw025 + grw026 + grw027 + grw028);
            "grw018": lambda county: 1,
            "grw019": lambda county: 1,
            "grw020": lambda county: 1,
            "grw021": lambda county: 1,
            "grw022": lambda county: 1,
            "grw023": lambda county: 1,
            "grw024": lambda county: 1,
            "grw025": lambda county: 1,
            "grw026": lambda county: 1,
            "grw027": lambda county: 1,
            "grw028": lambda county: 1,

            ## c.Black_avgage: median age of blacks (NOT average)
            # relevant code from censusage.do:
            # rename fm8002 Black_avgage;
            # save "$outfile\censusage", replace;
            # NOTE: assuming age can be at most 120; then median has global sensitivity 60
            "Black_avgage": lambda county: 120/2,

            ## c.Black_Earnings: monthly earnings of Blacks
            # relevant code from Createmain.do:
            # merge m:1 fips using "$infile/earnings_QWI";
            # ASSUMPTION: 2010 population is known, all earnings within 3 stdevs (1 stdev = 292, mean 2010)
            # NOTE: can't do this one, black pop doesn't exist in this file, would have to do manaul join
            # "Black_Earnings": lambda county: 2010+282*3 / county["Black_POP_2010"],

            ## c.share_maritalblacks
            # relevant code from Createmain.do, Marital.do:
            # use "$infile/maritalcensus_temp";
            # ...
            # generate share_maritalblacks = (j0ye004 + j0ye005 + j0ye010 + j0ye011)/j0ye001;
            "j0ye004": lambda county: 1,
            "j0ye005": lambda county: 1,
            "j0ye010": lambda county: 1,
            "j0ye011": lambda county: 1,
            "j0ye001": lambda county: 1,
        }
        if year_cutoff < 1900: # these data from 1900 census
            ## lynchcapitamob: HISTORICAL DATA
            # relevant code from Createmain.do:
            # merge m:1 County State using "$infile2/lynchcorrectblacksnomob";
            # replace lynchingmob = 0 if _merge == 1 & (State == "North Carolina"|State =="Louisiana"|State =="Georgia"|State =="Alabama"|State =="South Carolina"|State=="Florida");
            # ...
            # merge m:1 fips using "$infile2/POP_1900_NHGIS";
            # ...
            # generate lynchcapitamob = (lynchingmob/Black_POP_1900)*10000;
            vars_to_noise["POP_1900_NHGIS"] = lambda county: 1
            vars_to_noise["lynchingmob"] = lambda county: 1

            ## lynchcapitawhite: HISTORICAL DATA
            # relevant code from Createmain.do:
            # merge m:1 County State using "$infile2/lynchcorrectwhites";
            # replace lynchingmobwhite = 0 if _merge == 1 & (State == "North Carolina"|State =="Louisiana"|State =="Georgia"|State =="Alabama"|State =="South Carolina"|State=="Florida");
            # generate lynchcapitawhite = (lynchingmobwhite/White_POP_1900)*10000;
            vars_to_noise["lynchingmobwhite"] = lambda county: 1
        
        if year_cutoff < 1910: # these data are from 1910 census
            ## c.Black_share_illiterate
            # relevant code from Createmain.do: 
            # merge m:1 fips using "$infile2/illiterate_NHGIS";
            # ...
            # merge m:1 fips using "$infile2/votingage1910";
            # ...
            # generate Black_share_illiterate = (Black_illiterate/Black_votingage)*10000;
            vars_to_noise["Black_illiterate"] = lambda county: 1
            vars_to_noise["Black_votingage"] = lambda county: 1
        
        if year_cutoff < 1860:
            ## c.sfarmprop1860

            ## c.landineq1860

            ## c.fbprop1860

            ## c.newscapita
            # generate newscapita = (newspaper/Total_POP_1840)*10000;

            raise NotImplementedError("Data before 1860 not yet implemented")

        return vars_to_noise

    def extract_results(self) -> list[Result]:
        results = []
        table2 = self._load_esttab(f"{self.path()}/results/Table2.csv")
        results.append(Result.from_esttab(
            id="lynchcapitamob-Blackrate_regvoters",
            table=table2,
            row="lynchcapitamob",
            col="b1",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="lynchcapitawhite-Whiterate_regvoters",
            table=table2,
            row="lynchcapitawhite",
            col="w2",
            expected_range=(0, 0)
        ))
        table5 = self._load_esttab(f"{self.path()}/results/Table5.csv")
        results.append(Result.from_esttab(
            id="lynchcapitamob-Blackrate_regvoters2",
            table=table5,
            row="lynchcapitamob",
            col="t5",
            expected_range=(None, 0)
        ))
        return results