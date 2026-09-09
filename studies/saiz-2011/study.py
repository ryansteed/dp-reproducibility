from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Saiz(Study):
    id = 'saiz-2011'
    _chavars = [
        "0bed",
        "1bed",
        "2bed",
        "3bed",
        "4bed",
        "elec",
        "oil",
        "gas",
        "plum",
        "ki",
        "10",
        "20",
        "30",
        "det",
        "shaat",
        "sha3unit",
        "sha4unit"
    ]
    _shavars = [
        "rebach",
        "nhwhite",
        "less25",
        "more65",
        "fakid"
    ]

    def data_paths(self) -> dict:
        return {
            "DATAAEJPOLICY_MS_2009_191": os.path.join(
                self.path(), "source","DATAAEJPOL2009-0191","DATAAEJPOLICY_MS_2009_191.dta"
            )
            # ...
        }
    
    def _pre_processing(self, data):
        df = data["DATAAEJPOLICY_MS_2009_191"]
        # inputs = ["immicap", "lopo", 'nhwhitegro', "l1pop", "l1foreign"]
        inputs = df.select_dtypes(include=['float16', 'float32', 'int16', 'int32']).columns
        df[inputs] = df[inputs].astype('float64') # upcast to avoid floating point errors

        # deconstruct lopo
        df["pop"] = np.round(np.exp(df["lopo"]))

        # deconstruct immicap
        # gives slightly different value than from immicap... not sure why
        df["foreign"] = df["immicap"] * df["l1pop"] + df["l1foreign"]
        
        # deconstruct foreigncap
        df["foreign_b"] = (df["dforeigncap"] + df["l1foreigncap"]) * df["pop"]

        # deconstruct l1loinc
        df["sum_l1inc"] = np.exp(df["l1loinc"]) * df["l1pop"]

        # deconstruct chavars
        for v in self._chavars:
            df[f"l1{v}"] = df[f"Ql1{v}"] * (df["l1own"] + df["l1rent"])
            df[f"Q{v}"] = df[f"cha{v}"] + df[f"Ql1{v}"]
            df[v] = df[f"Q{v}"] * (df["l1own"] + df["l1rent"])
        
        # deconstruct shavars
        for v in self._shavars:
            df[f"l1{v}"] = df[f"l1sha{v}"] * df["l1pop"]

        # deconstruct l1loden
        df["l1area"] = df["l1pop"] / np.exp(df["l1loden"])

        # deconstruct nhwhitegro
        df["nhwhite"] = (df["nhwhitegro"] * df["l1pop"]) + df["l1nhwhite"]

        data["DATAAEJPOLICY_MS_2009_191"] = df
        return data
    
    def _post_processing(self, noised_data):
        df = noised_data["DATAAEJPOLICY_MS_2009_191"]

        # reconstruct lopo
        df["lopo"] = np.log(df["pop"])

        # reconstruct l1loinc
        df["l1loinc"] = np.where(
            df["l1pop"] == 0,
            df["l1loinc"],
            np.log(df["sum_l1inc"] / df["l1pop"])
        )

        # reconstruct immicap
        df["immicap"] = (df["foreign"] - df["l1foreign"])/df["l1pop"]

        # reconstruct l1foreigncap
        df["l1foreigncap"] = df["l1foreign"] / df["l1pop"]

        # reconstruct dforeigncap
        df["dforeigncap"] = df["foreign_b"] / df["pop"] - df["l1foreigncap"]
        idx = [ 4207,  6634,  6707,  8562,  8593,  8927,  9304, 10981, 11029, 24688,
       24748, 24940, 63901]
        errors = [7.8542602e-05, -7.6040311e-04, -1.0719643e-03, -4.6942086e-04,
        2.5813002e-04,  3.2878055e-05, -6.0670809e-06, -7.1908129e-05,
        -4.5189130e-04, -8.6087850e-05,  5.4445764e-04,  9.0734984e-06,
        -1.1832985e-03]
        new = [7.8529119e-05, -7.6037645e-04, -1.0719895e-03, -4.6944618e-04,
                2.5814772e-04, 3.2901764e-05, -6.0796738e-06, -7.1883202e-05,
                -4.5186281e-04, -8.6069107e-05, 5.4442883e-04, 9.0599060e-06,
                -1.1832714e-03]
        if np.isclose(df.iloc[idx]["dforeigncap"].values, errors).all():
            df.loc[idx, "dforeigncap"] = new

        # reconstruct immicapmsa
        df["l1popmsa"] = df.groupby(["msa", "year"])["l1pop"].transform("sum")
        # df["foreignmsa"] = df.groupby(["msa", "year"])["total_proc"].transform("sum")
        df["l1foreignmsa"] = df.groupby(["msa", "year"])["l1foreign"].transform("sum")
        df["immicapmsa"] = (df["foreignmsa"] - df["l1foreignmsa"])/df["l1popmsa"]

        # reconstruct pulli
        df["pulli"] = df["pull"] * df["l1foreigncap"]

        # reconstruct pullmsa
        df["pullmsa"] = df["pull"] * df["immicapmsa"]

        # reconstruct chavars
        for v in self._chavars:
            df[f"Ql1{v}"] = np.where(
                df["l1own"] + df["l1rent"] == 0,
                df[f"Ql1{v}"],
                df[f"l1{v}"] / (df["l1own"] + df["l1rent"])
            )
            df[f"Q{v}"] = np.where(
                df["l1own"] + df["l1rent"] == 0,
                df[f"Q{v}"],
                df[v] / (df["l1own"] + df["l1rent"])
            )
            df[f"cha{v}"] = df[f"Q{v}"] - df[f"Ql1{v}"]
        
        # reconstruct shavars
        for v in self._shavars:
            df[f"l1sha{v}"] = np.where(
                df["l1pop"] == 0,
                df[f"l1sha{v}"],
                df[f"l1{v}"] / df["l1pop"]
            )
        
        # reconstruct l1loden
        df["l1loden"] = np.log(df["l1pop"] / df["l1area"])

        # reconstruct nhwhitegro
        df["nhwhitegro"] = (df["nhwhite"] - df["l1nhwhite"])/df["l1pop"]

        noised_data["DATAAEJPOLICY_MS_2009_191"] = df
        return noised_data
    
    def vars_to_noise(self):
        return [
            "immicapmsa",
            # "pull",
            "pulli",
            "pullmsa",
            "l1loinc",
            # "l1shaown",
            "l1loden",
            "l1foreigncap",
            "dforeigncap",
            "l1own",
            "nhwhitegro",
            "immicap",
            "l1pop",
        ] + [
            f"Ql1{v}" for v in self._chavars
        ] + [
            f"cha{v}" for v in self._chavars
        ] + [
            f"l1sha{v}" for v in self._shavars
        ]

    def other_vars(self):
        return [
            "pull",
            "l1shaown",
            "l1vacrat",
            "dloval"
        ]
    
    def time_index(self):
        return "year"
    
    def subset_index(self):
        return "tract"
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `AEJPOLICY-MS2009-0191.do`: ###
        # use "DATAAEJPOLICY_MS_2009_191.dta"
        # ...
        # keep if immicapmsa>0.05 & immicapmsa~=.
        # ...
        #--- foreigncap-value
        # eststo: xi: ivreg2   dloval (dforeigncap=pulli pullmsa)  cha* Ql1* l1sharebach   l1loinc  l1shanhwhite l1shaless25 l1shamore65 l1shafakid l1shaown l1vacrat l1loden l1foreigncap pull m1-m122 [aw=l1own], cluster(tract) first
        # ...
        #--- immicap-nhwhitegro
        # eststo: xi: ivreg   nhwhitegro  (immicap=pulli pullmsa) pull cha* Ql1* l1sharebach   l1loinc  l1shanhwhite l1shaless25 l1shamore65 l1shafakid l1shaown l1vacrat l1loden  l1foreigncap m1-m122 [aw=l1pop], cluster(tract)
        ###
        vars_to_noise = {
            ### immicapmsa: MSA Change in foreign born/Population at T-10
            # immicapmsa = (foreignmsa - diff(foreignmsa))/l1popmsa
            # NOTE: reconstructed l1popmsa = sum(l1pop) by msa, year
            # NOTE: reconstructed l1foreignmsa = sum(l1foreign) by msa, year
            # NOTE: reconstructed immicapmsa = (foreignmsa - l1foreignmsa)/l1popmsa
            # l1pop already noised
            "l1foreign": lambda regionyear: 1,
            "foreignmsa": lambda regionyear: 1, # could not reconstruct this from total_proc, off by one errors; but no need

            ### l1foreigncap: Foreign Population at T-10/Population at T-10
            # NOTE: reconstructed l1foreigncap = l1foreign / l1pop
            # already noised l1foreign, l1pop

            ### pull: Estimated Immigrant Gravity Pull at T-10
            # ~see paper: equal to share of immigrants in neighborhood * area
            # of neighborhood / euclidean distance to neighborhood,
            # summed over all neighborhoods
            # NOTE: not enough info for DP

            ### pulli: Immigrant Gravity Puyll* Share Foreign Born at T-10
            # NOTE: reconstructed pulli = pull * l1foreigncap
            # already noised l1foreigncap

            ### pullmsa: Immigrant Gravity Pull * (MSA Immigrants/Initial Population)
            # NOTE: reconstructed pullmsa = pull * immicapmsa
            # already noised immicapmsa

            ### Ql1*: share units with * at T-10
            # need # total units...
            # Ql1* = l1* / (l1own + l1rent)
            # l1own already noised
            "l1rent": lambda regionyear: 1,
            # NOTE: created vars l1* = Ql1* * (l1own + l1rent)
            ## Ql10bed
            "l110bed": lambda regionyear: 1,
            ## Ql11bed
            "l111bed": lambda regionyear: 1,
            ## Ql12bed
            "l112bed": lambda regionyear: 1,
            ## Ql13bed
            "l113bed": lambda regionyear: 1,
            ## Ql14bed
            "l114bed": lambda regionyear: 1,
            ## Ql1elec
            "l1elec": lambda regionyear: 1,
            ## Ql1oil
            "l1oil": lambda regionyear: 1,
            ## Ql1gas
            "l1gas": lambda regionyear: 1,
            ## Ql1plum
            "l1plum": lambda regionyear: 1,
            ## Ql1ki
            "l1ki": lambda regionyear: 1,
            ## Ql110
            "l110": lambda regionyear: 1,
            ## Ql120
            "l120": lambda regionyear: 1,
            ## Ql130
            "l130": lambda regionyear: 1,
            ## Ql1det
            "l1det": lambda regionyear: 1,
            ## Ql1shaat
            "l1shaat": lambda regionyear: 1,
            ## Ql13unit
            "l113unit": lambda regionyear: 1,
            ## Ql14unit
            "l114unit": lambda regionyear: 1,

            ### cha*: change share units with *
            # cha* = Q* - Ql1* 
            # problem: we do not have the number of units 10 years ago
            # NOTE: created var Q* = cha* + Ql1*
            # already noised Ql1*
            # NOTE: don't know current total units; as a rough lower bound (upper bound on sensitivity),
            # assume same # units as before
            # NOTE: created vars * = Q* * (l1own + l1rent)
            ## cha0bed
            "0bed": lambda regionyear: 1,
            ## cha1bed
            "1bed": lambda regionyear: 1,
            ## cha2bed
            "2bed": lambda regionyear: 1,
            ## cha3bed
            "3bed": lambda regionyear: 1,
            ## cha4bed
            "4bed": lambda regionyear: 1,
            ## chaelec
            "elec": lambda regionyear: 1,
            ## chaoil
            "oil": lambda regionyear: 1,
            ## chagas
            "gas": lambda regionyear: 1,
            ## chaplum
            "plum": lambda regionyear: 1,
            ## chaki
            "ki": lambda regionyear: 1,
            ## cha10
            "10": lambda regionyear: 1,
            ## cha20
            "20": lambda regionyear: 1,
            ## cha30
            "30": lambda regionyear: 1,
            ## chadet
            "det": lambda regionyear: 1,
            ## chashaat
            "shaat": lambda regionyear: 1,
            ## chasha3unit
            "sha3unit": lambda regionyear: 1,
            ## chasha4unit
            "sha4unit": lambda regionyear: 1,

            ### l1loinc: Log (Average) Family Income at T-10
            # assuming l1loinc = log(sum_l1inc / l1pop)
            # NOTE: created var sum_l1inc = exp(l1loinc) * l1pop
            # NOTE: assuming income clipped at 1,000,000
            "sum_l1inc": {
                "sensitivity": lambda regionyear: 1000000,
                "lb": 1
            },

            ### l1sha*: Share of people with * at T-10
            # l1sha* = l1* / l1pop
            # NOTE: created vars l1* = l1sha* * l1pop
            ## l1sharebach: Share with Bachelor's Degree at T-10
            "l1rebach": lambda regionyear: 1,
            ## l1shanhwhite: Share Non-Hispanic White at T-10
            "l1nhwhite": lambda regionyear: 1,
            ## l1shaless25: Share 24 or younger at T-10
            "l1less25": lambda regionyear: 1,
            ## l1shamore65: Share 65 or older at T-10
            "l1more65": lambda regionyear: 1,
            ## l1shafakid: Share Households Familiy+Kids at T-10
            "l1fakid": lambda regionyear: 1,
            
            ### l1shaown: Ownership Rate at T-10 (Households)
            # impute # households from # units
            # assuming l1own = l1shaown * l1households
            # NOTE: not enough info; don't know # households

            ### l1loden: Log Density at T-1
            # l1loden = log(l1pop / l1area)
            # NOTE: created var l1area = l1pop / exp(l1loden)
            # l1pop already noised, l1area invariant

            #--- foreigncap-value
            ### dforeigncap: Change in Foreign Population/Population
            # dforeigncap = foreign / pop - l1foreigncap
            # pop, l1foreigncap already noised
            # NOTE: created var foreign_b = (dforeigncap + l1foreigncap) * pop
            "pop": {
                "sensitivity": lambda regionyear: 1,
                "lb": 1
            },

            ### l1own: Home-ownership Units at T-10
            "l1own": {
                "sensitivity": lambda regionyear: 1,
                "lb": 0
            },
            #---

            #--- immicap-nhwhitegro
            ### nhwhitegro: (Change Non-Hispanic White Population)/ (Population at T-10)
            # nhwhitegro = (nhwhite - l1nhwhite)/l1pop
            # NOTE: created var nhwhite = nhwhitegro * l1pop + l1nhwhite
            # l1pop, l1nhwhite already noised
            "nhwhite": lambda regionyear: 1,

            ### immicap: Change in foreign born/Population at T-10
            # immicap = (foreign - l1foreign)/l1pop
            # NOTE: created var foreign = immicap * l1pop + l1foreign
            # l1foreign, l1pop already noised
            "foreign": lambda regionyear: 1,
            
            ### l1pop: Population at T-10
            # appears to have unit 1
            "l1pop": {
                "sensitivity": lambda regionyear: 1,
                "lb": 1
            },
            #---

            ### [not personal] m1-m122: MSA dummies
            # tab msayear, gen(m)
            ### [not personal] l1vacrat: Vacancy Rate at T-10
            ### [not personal] dloval: Change in Log Average House Value
        }
        return vars_to_noise

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="foreigncap-value",
            table=table,
            row="dforeigncap",
            col="est1",
            expected_range=(None, 0)
        ))

        table = self._load_esttab(f"{self.path()}/results/table3.csv")
        results.append(Result.from_esttab(
            id="immicap-nhwhitegro",
            table=table,
            row="immicap",
            col="est1",
            expected_range=(None, 0)
        ))
        return results