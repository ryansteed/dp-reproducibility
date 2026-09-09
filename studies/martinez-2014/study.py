from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Martinez(Study):
    id = 'martinez-2014'

    def data_paths(self) -> dict:
        return {
            "LocalOfficials_AER": os.path.join(
                self.path(), "source/AER-2011-1027.R2_Data", "LocalOfficials_AER.dta"
            )
            # ...
        }
    
    def _pre_processing(self, data: Dict[str, pd.DataFrame]) -> Dict[str, pd.DataFrame]:
        df = data["LocalOfficials_AER"]

        # deconstructing popdensity_1996
        df["area_1996"] = df["population_1996"] / df["popdensity_1996"]

        # deconstructing *ph_1996, *_1996_pc
        for v in [
            "mosqueph_1996",
            "prayerhouseph_1996",
            "churchesph_1996",
            "viharaph_1996",
            "num_TVs_1996_pc",
            "num_hospitals_1996_pc",
            "num_maternhosp_1996_pc",
            "num_polyclinic_1996_pc",
            "num_puskesmas_1996_pc",
            "num_kindgarden_1996_pc",
            "num_primarysch_1996_pc",
            "num_HS_1996_pc"
        ]:
            # v = num / population_1996 * 1000
            # num = v * population_1996 / 1000
            df[f"{v}_num"] = df[v] * df["population_1996"] / 1000

        data["LocalOfficials_AER"] = df
        return data
    
    def _post_processing(self, noised_data) -> pd.DataFrame:
        df = noised_data["LocalOfficials_AER"]
        
        # reconstructing perc_ruralHH*
        df["perc_ruralHH_1996"] = df["num_HH_rural_1996"] / df["num_HH_1996"] * 100
        df["perc_ruralHH_1996_2"] = df["perc_ruralHH_1996"] ** 2
        df["perc_ruralHH_1996_3"] = df["perc_ruralHH_1996"] ** 3
        df["perc_ruralHH_1996_4"] = df["perc_ruralHH_1996"] ** 4

        # reconstructing lpopulation_1996*
        df["lpopulation_1996"] = np.log(df["population_1996"])
        df["lpopulation_1996_2"] = df["lpopulation_1996"] ** 2
        df["lpopulation_1996_3"] = df["lpopulation_1996"] ** 3
        df["lpopulation_1996_4"] = df["lpopulation_1996"] ** 4

        # reconstructing popdensity_1996
        df["popdensity_1996"] = df["population_1996"] / df["area_1996"]

        # reconstructing *ph_1996, *_1996_pc
        for v in [
            "mosqueph_1996",
            "prayerhouseph_1996",
            "churchesph_1996",
            "viharaph_1996",
            "num_TVs_1996_pc",
            "num_hospitals_1996_pc",
            "num_maternhosp_1996_pc",
            "num_polyclinic_1996_pc",
            "num_puskesmas_1996_pc",
            "num_kindgarden_1996_pc",
            "num_primarysch_1996_pc",
            "num_HS_1996_pc"
        ]:
            # v = num / population_1996 * 1000
            # num = v * population_1996 / 1000
            df[v] = df[f"{v}_num"] / df["population_1996"] * 1000

        noised_data["LocalOfficials_AER"] = df
        return noised_data
    
    def vars_to_noise(self) -> list:
        return [
            "perc_ruralHH_1996",
            "perc_ruralHH_1996_2",
            "perc_ruralHH_1996_3",
            "perc_ruralHH_1996_4",
            "lpopulation_1996",
            "lpopulation_1996_2",
            "lpopulation_1996_3",
            "lpopulation_1996_4",
            "popdensity_1996",
            "mosqueph_1996",
            "prayerhouseph_1996",
            "churchesph_1996",
            "viharaph_1996",
            "num_TVs_1996_pc",
            "num_hospitals_1996_pc",
            "num_maternhosp_1996_pc",
            "num_polyclinic_1996_pc",
            "num_puskesmas_1996_pc",
            "num_kindgarden_1996_pc",
            "num_primarysch_1996_pc",
            "num_HS_1996_pc"
        ]
    
    def other_vars(self):
        return [
            "urbDum_1996",
            "ShareRurLand_1996",
            "altitude_high_1996",
            "dist_kecoffice_2000",
            "dist_kab_kotacapital_2000",
            "kelurDum",
            # "idkab_dum*", # generated var from kab
            "kab", # district
            "GolkarFirst",
            "PDIFirst"
        ]
    
    def subset_index(self):
        return "kab"

    def time_index(self):
        return None
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `LocalOfficials_AER.do`:
        # global geography "urbDum_1996 
        # perc_ruralHH_1996 perc_ruralHH_1996_2 perc_ruralHH_1996_3 perc_ruralHH_1996_4 
        # ShareRurLand_1996  altitude_high_1996 lpopulation_1996* popdensity_1996 
        # dist_kecoffice_2000 dist_kab_kotacapital_2000";
        # global religion "mosqueph_1996 prayerhouseph_1996 churchesph_1996 viharaph_1996"  ;
        # global facilities "num_TVs_1996_pc   
        # num_hospitals_1996_pc num_maternhosp_1996_pc num_polyclinic_1996_pc num_puskesmas_1996_pc 
        # num_kindgarden_1996_pc num_primarysch_1996_pc  num_HS_1996_pc" ;

        # Table 2 col 5
        # reg GolkarFirst kelurDum $geography $religion $facilities idkab_d*, vce(cluster kab)

        # Table 3 col 2
        # foreach var of varlist GolkarFirst  PDIFirst { 
        # eststo: reg `var' kelurDum  $geography $religion $facilities 
        # ...
        # }
        ###
        ### vars:
        # [not personal data] GolkarFirst: =1 if Golkar most voted party in village in 1999
        # [not personal data] PDIFirst: =1 if PDI most voted party in village in 1999
        # [not personal data] kelurDum: =1 if village is a kelurahan
        # [not personal data] urbDum_1996: =1 if village considered urban by BPS
        # [not personal data] ShareRurLand_1996: Share of agricultural land in the village
        # [not personal data] altitude_high_1996: high altitude village
        # [not personal data] dist_kecoffice_2000: Distance to the kecamatan office in km
        # [not personal data] dist_kab_kotacapital_2000: Distance to the kabupaten / kota capital in km
        # perc_ruralHH_1996: percentage of HH whose main occupation is in aggriculture
        # perc_ruralHH_1996_2: perc_ruralHH_1996^2
        # perc_ruralHH_1996_3: perc_ruralHH_1996^3
        # perc_ruralHH_1996_4: perc_ruralHH_1996^4
        # lpopulation_1996: log number of population in the village 1996
        # lpopulation_1996_2: lpopulation_1996^2
        # lpopulation_1996_3: lpopulation_1996^3
        # lpopulation_1996_4: lpopulation_1996^4
        # popdensity_1996: population density (# people/ha)
        # mosqueph_1996: number of mosques per 1,000 people
        # prayerhouseph_1996: number of prayer houses per 1,000 people
        # churchesph_1996: number of churches per 1,000 people
        # viharaph_1996: number of Buddhist temples per 1,000 people
        # num_TVs_1996_pc: number of TVs per 1,000 people   
        # num_hospitals_1996_pc: number of hospitals per 1,000 people
        # num_maternhosp_1996_pc: number of maternity hospitals per 1,000 people
        # num_polyclinic_1996_pc: number of polyclinic per 1,000 people
        # num_puskesmas_1996_pc: number of puskesmas per 1,000 people
        # num_kindgarden_1996_pc: number of kinder garten per 1,000 people
        # num_primarysch_1996_pc: number of primary School per 1,000 people
        # num_HS_1996_pc: number of High School per 1,000 people
        ###
        vars_to_noise = {
            ### perc_ruralHH_1996*
            ## perc_ruralHH_1996: percentage of HH whose main occupation is in aggriculture
            ## perc_ruralHH_1996_2: perc_ruralHH_1996^2
            ## perc_ruralHH_1996_3: perc_ruralHH_1996^3
            ## perc_ruralHH_1996_4: perc_ruralHH_1996^4
            # helpfully, we have num_HH_1996 and num_HH_rural_1996
            # NOTE assumption: protecting at household level, not individual level
            "num_HH_1996": lambda village: 1,
            "num_HH_rural_1996": lambda village: 1,

            ### lpopulation_1996*
            ## lpopulation_1996: log number of population in the village 1996
            ## lpopulation_1996_2: lpopulation_1996^2
            ## lpopulation_1996_3: lpopulation_1996^3
            ## lpopulation_1996_4: lpopulation_1996^4
            # helpfully, we have population_1996
            "population_1996": lambda village: 1,
            ## popdensity_1996: population density (# people/ha)
            # reconstructing from population_1996
            # CREATED INTER VAR area_1996

            ### *ph_1996, *_1996_pc
            ## mosqueph_1996: number of mosques per 1,000 people
            ## prayerhouseph_1996: number of prayer houses per 1,000 people
            ## churchesph_1996: number of churches per 1,000 people
            ## viharaph_1996: number of Buddhist temples per 1,000 people
            ## num_TVs_1996_pc: number of TVs per 1,000 people   
            ## num_hospitals_1996_pc: number of hospitals per 1,000 people
            ## num_maternhosp_1996_pc: number of maternity hospitals per 1,000 people
            ## num_polyclinic_1996_pc: number of polyclinic per 1,000 people
            ## num_puskesmas_1996_pc: number of puskesmas per 1,000 people
            ## num_kindgarden_1996_pc: number of kinder garten per 1,000 people
            ## num_primarysch_1996_pc: number of primary School per 1,000 people
            ## num_HS_1996_pc: number of High School per 1,000 people
            # CREATED INTER VARS *_num, reconstructed with population_1996
        }
        return vars_to_noise

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/Table2Col5.csv")
        results.append(Result.from_esttab(
            id="kelurDum-GolkarFirst",
            table=table,
            row="kelurDum",
            col="est1",
            expected_range=(0, None)
        ))
        table = self._load_esttab(f"{self.path()}/results/Table3Col2.csv")
        results.append(Result.from_esttab(
            id="kelurDum-PDIFirst",
            table=table,
            row="kelurDum",
            col="est2",
            expected_range=(0, None)
        ))
        return results