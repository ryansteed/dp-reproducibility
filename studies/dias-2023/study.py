from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Dias(Study):
    id = 'dias-2023'

    def data_paths(self) -> dict:
        return {
            "data_final": os.path.join(
                self.path(), "source/Data/Workfiles", "data_final.dta"
            )
            # ...
        }
    
    def _post_processing(self, noised_data) -> pd.DataFrame:
        df = noised_data["data_final"]

        # reconstruct IMR
        df["IMR"] = 1000 * (df["baby_death"] / df["births"])

        # reconstruct l_gdppc
        df["l_gdppc"] = np.log(df["gdp"] / df["population"])

        # reconstruct hospital_beds_pc
        df["hospital_beds_pc"] = (df["hosp_beds"] / df["population"]) * 1000

        # reconstruct coverage_psf, coverage_pbf
        for v in ["psf", "pbf"]:
            df[f"coverage_{v}"] = df[v] / df["population"]
            df.loc[df[f"coverage_{v}"] > 1, f"coverage_{v}"] = 1

        noised_data["data_final"] = df
        return noised_data

    def _clean(self, noised_data) -> pd.DataFrame:
        df = noised_data["data_final"]
        # reconstruct weight
        df["weight"] = df.groupby("AMC")["births"].transform("mean")
        noised_data["data_final"] = df
        return noised_data
    
    def vars_to_noise(self) -> list:
        return [
            "IMR",
            "l_gdppc",
            "hospital_beds_pc",
            "coverage_psf",
            "coverage_pbf",
            "weight"
        ]
    
    def collinear_vars(self):
        return ["weight"]

    def other_vars(self):
        return [
            "glyph_soy_upstream",
            "potentialUpstream",
            "potentialAMC",
            "d_hosp",
            "share_GDPagro",
            # "int_uf*", # created var from year, uf
            "basin"
        ]

    def subset_index(self):
        return "uf"
    
    def time_index(self):
        return "year"
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code:
        # global glyph_up "glyph_soy_upstream"
        # global instr "potentialUpstream" 
        # global control "potentialAMC l_gdppc hospital_beds_pc d_hosp coverage_psf coverage_pbf share_GDPagro int_uf* [w=weight]"
        # xi: xtivreg2 IMR ($glyph_up=$instr) $control, fe cluster(basin) partial(int_uf*)
        ###
        ### vars:
        # [not personal data] glyph_soy_upstream: Glyphosate Upstream
        # [not personal data] potentialUpstream: Instrument: Upstream (gain in soybean productivity)
        # [not personal data] potentialAMC: Instrument: Direct effect
        # [not personal data] share_GDPagro: Share of GDP Agro
        # [not personal data] int_uf*: Fixed effects?
        # IMR: infant mortality rate
        # l_gdppc: Log of GDP per capita
        # hospital_beds_pc: Hospital beds per capita?
        # [not personal data] d_hosp: Presence of hospitals
        # coverage_psf: Covered by family health program?
        # coverage_pbf: Covered by family health program?
        # weight: mean number of births over entire sample period
        ###
        vars_to_noise = {
            ## IMR: infant mortality rate
            # [not run] gen IMR = 1000 * (baby_death/births)
            # RECONSTRUCTED
            "baby_death": lambda municipality: 1,
            "births": {
                "sensitivity": lambda municipality: 1,
                "lb": 1
            },
            
            ### per capita vars
            "population": lambda municipality: 1,
            ## l_gdppc: Log of GDP per capita
            # [not run] gen l_gdppc=log(gdp/population)
            # RECONSTRUCTED
            ## hospital_beds_pc: Hospital beds per capita?
            # [not run] gen hospital_beds_pc = (hosp_beds/population)*1000
            # RECONSTRUCTED
            ## coverage_psf: Covered by family health program
            # [not run] gen coverage_psf = psf/population
            # [not run] replace coverage_psf = 1 if coverage_psf>1
            # RECONSTRUCTED
            "psf": lambda municipality: 1,
            ## coverage_pbf: Covered by family health program
            # [not run] gen coverage_pbf = pbf/population
            # [not run] replace coverage_pbf = 1 if coverage_pbf>1
            # RECONSTRUCTED
            "pbf": lambda municipality: 1,
            
            ## weight: mean number of births over entire sample period
            # [not run] sort AMC
            # [not run] by AMC: egen weight=mean(births)
            # RECONSTRUCTED; no need for sensitivity, just need bounds
        }
        return vars_to_noise

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/Table2.csv")
        results.append(Result.from_esttab(
            id="glyph_soy_upstream-IMR",
            table=table,
            row="glyph_soy_upstream",
            col="est9",
            expected_range=(0, None)
        ))
        return results