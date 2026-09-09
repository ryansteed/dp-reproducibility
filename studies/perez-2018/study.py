from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Perez(Study):
    id = 'perez-2018'

    def data_paths(self) -> dict:
        return {
            # "MonthlyUnemploymentRate": os.path.join(
            #     self.path(), "source", "Do_Files","2_data","BLS_LAU_MonthlyUnemploymentRates_","_al_MonthlyUnemploymentRate2001_2010.dta"
            # ),
            # "AllStates_MonthlyUnemploymentRate": os.path.join(
            #     self.path(), "source", "Do_Files","2_data","AllStates_MonthlyUnemploymentRate2001_2010.dta"
            # ),
            # "fed_m_final": os.path.join(
            #     self.path(), "source", "Do_Files","2_data/NASBO","fed_m_final.dta"
            # ),
            # "fed": os.path.join(
            #     self.path(), "source", "Do_Files","2_data/NASBO","fed.dta"
            # ),
            # "AllStates_JulyAnnualUnemploymentRate": os.path.join(
            #     self.path(), "source", "Do_Files","2_data","AllStates_JulyAnnualUnemploymentRate2001_2010.dta"
            # ),
            # "sim_elig_adults2": os.path.join(
            #     self.path(), "source", "Do_Files","2_data","sim_elig_adults2.dta"
            # ),
            # "adults_ivsample": os.path.join(
            #     self.path(), "source", "Do_Files","2_data","adults_ivsample.dta"
            # ),
            # "AllStates_MonthlyUnemploymentRate": os.path.join(
            #     self.path(), "source", "Do_Files","2_data","AllStates_MonthlyUnemploymentRate2001_2010.dta"
            # )
            # ...
            f"st_{st}": os.path.join(
                self.path(), "source", "Do_Files","2_data", "BLS_LAU_MonthlyUnemploymentRates_", f"_{st}.txt"
            ) for st in [
                "al", "ak", "az", "ar", "ca", "co", "ct", "de", "dc", "fl",
                "ga", "hi", "id", "il", "ind", "ia", "ks", "ky", 
                "la", 
                "me",
                "md", "ma", "mi", "mn", "ms", "mo", "mt", "ne", "nv", "nh",
                "nj", "nm", "ny", "nc", "nd", "oh", "ok", "or", "pa", "ri",
                "sc", "sd", "tn", "tx", "ut", "vt", "va", "wa", "wv", "wi",
                "wy"
            ]
        }
    
    def _load_data_from_paths(self, paths):
        data = super()._load_data_from_paths(paths)
        self._decimals = {}
        for name in data.keys():
            df = data[name]
            # get number of decimals in each string
            self._decimals[name] = np.where(
                df["value"].str.contains("\."),
                df["value"].str.split("\.").str.get(1).str.len(),
                0
            )
            df["value"] = df["value"].astype(str).str.strip().replace(
                "-", np.nan
            ).astype(float)
            data[name] = df
        return data
    
    def _save_data_to_paths(self, data, paths):
        for name in data.keys():
            df = data[name]
            # round to precision of original value
            df["value"] = np.where(
                df["value"].isna(),
                "-",
                np.where(
                    self._decimals[name] == 0,
                    df["value"].fillna(-1).astype(int).astype(str),
                    df["value"].astype(str)
                )
            )
            data[name] = df.astype(str).drop(columns=["datatype", "valuetype"])
        return super()._save_data_to_paths(data, paths)
    
    def _read_csv(self, path, sep=","):
        return pd.read_csv(path, sep="\t", dtype=str).apply(lambda x: x.str.strip())

    
    def _post_processing(self, noised_data):
        for name in noised_data.keys():
            df = noised_data[name].copy()
            if name.startswith("st"):
                df["datatype"] = df["series_id"].str.slice(0, 5).str.strip()
                df["valuetype"] = df["series_id"].str.slice(18, 25).str.strip()
                unemp_rate = (df["valuetype"] == "03") & (df["datatype"] == "LASST")
                unemp = (df["valuetype"] == "04") & (df["datatype"] == "LASST")
                lf = (df["valuetype"] == "06") & (df["datatype"] == "LASST")
                assert unemp_rate.sum() == unemp.sum() == lf.sum()
                values_new = np.round(
                    df[unemp]["value"].values / df[lf]["value"].values * 100,
                    1
                )
                df.loc[unemp_rate, "value"] = values_new
            noised_data[name] = df
        return noised_data
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `Step4_StateLevelRegressions_MedicaidEligibilityRankings_on_StateUnemployment_8-20-17.do.do`: ###
        # use $DATA/AllStates_JulyAnnualUnemploymentRate2001_2010.dta
        # ...
        # merge 1:1 st_fips year using "$DATA/sim_elig_adults2.dta"
        # ...
        # quietly xtreg sim_mcd_elig ann_unempl, fe
        # ...
        # quietly xtreg sim_mcd_elig  c.ann_unempl##(int_recess post_recess) , fe
        # ...
        ###
        vars_to_noise = {
            ### sim_mcd_elig: %Medicaid Eligible [*SIMULATED]
            ## constructed from mcd_elig, Step1*.do:
            # gen mcd_elig = 0;
            # ...
            # generate sim_mcd_elig = .;
            # ...
            # egen temp = mean(mcd_elig ) if age >=18, by(year);
            # replace sim_mcd_elig = temp if gestcen == `1' & age>=18;
            # ...
            # drop if sim_mcd_elig == .;
            # keep year gestcen sim_mcd_elig;
            # mcd_elig is modified by mcd20**elig.do based on these ind-level vars:
            #-- adults_ivsample.dta
            ## age
            ## newpovlv
            ## female
            ## inprs --- based on age
            # gen infant=0;
			# replace infant=1 if age<1 & theType==3;
            # egen inprs=mean(infant),by(year spmfamunit);
            #--
            ## NOTE: based on individual data, not aggregate; no noise added

            #--- AllStates_JulyAnnualUnemploymentRate2001_2010.dta
            ### ann_unempl: %Unemployment [s,t], State Unemployment Rate [Averaged for Annual]
            # NOTE: constructed by authors
            # created in Step2*.do:
            # foreach ST in 	 al ak az ar ca co ct de dc fl ///
			# 		 ga hi id il ind ia ks ky la me ///
			# 		 md ma mi mn ms mo mt ne nv nh ///
			# 		 nj nm ny nc nd oh ok or pa ri ///
			# 		 sc sd tn tx ut vt va wa wv wi ///
			# 		 wy		{
            # quietly import delimited $DATA/BLS_LAU_MonthlyUnemploymentRates_/_`ST'.txt
            # ...
            # keep if datatype =="LASST" & valuetype=="03"
            # ...
            # rename value st_unempl_rt
            # ...
            # bysort st_fip year : egen ann_unempl = mean(st_unempl_rt)
            #     label var ann_unempl "State Unemployment Rate [Averaged for Annual]"
            # Based on BLS Data Viewer https://data.bls.gov/dataViewer/view/timeseries/LASST060000000000006,
            # labor force is stored in valuetype=="06"
            # altering value will alter both labor force and unemployment;
            # then unemployment rate will be reconstructed from these files
            "value": lambda x: 1,
            
            ### [not personal] int_recess
            # gen int_recess  = (year>=2007 & year<=2009)
            ### [not personal] post_recess
            #gen post_recess = (year>=2010)
        }
        return vars_to_noise
    
    def vars_to_noise(self):
        return [
            "sim_mcd_elig",
            "ann_unempl"
        ]

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table3.csv")
        results.append(Result.from_esttab(
            id="unemp-medicaid",
            table=table,
            row="ann_unempl",
            col="est_mod1",
            expected_range=(0, None)
        ))
        results.append(Result.from_esttab(
            id="unemp-medicaidandrecession",
            table=table,
            row="ann_unempl",
            col="est_mod2",
            expected_range=(0,0)
        ))
        results.append(Result.from_esttab(
            id="interact_unemprecess",
            table=table,
            row="1.int_recess#c.ann_unempl",
            col="est_mod2",
            expected_range=(0,0)
        ))
        results.append(Result.from_esttab(
            id="interact_unemppost",
            table=table,
            row="1.post_recess#c.ann_unempl",
            col="est_mod2",
            expected_range=(0,0)
        ))
        return results