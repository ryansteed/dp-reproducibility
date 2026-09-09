from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Ferraz(Study):
    id = 'ferraz-2011'

    def data_paths(self) -> dict:
        return {
            "corruptiondata_aer": os.path.join(
                self.path(), "source", "corruptiondata_aer.dta"
            )
            # ...
        }
    
    def _pre_processing(self, data):
        df = data["corruptiondata_aer"]

        # deconstruct purb
        df["nurb"] = df["pop"] * df["purb"]

        # deconstruct p_secundario
        df["n_secundario"] = df["pop"] * df["p_secundario"]

        # deconstruct lpib02
        df["pib_02"] = np.exp(df["lpib02"]) * df["pop"]

        # deconstruct lfunc_ativ
        df["func_ativ"] = np.exp(df["lfunc_ativ"])

        data["corruptiondata_aer"] = df
        return data
    
    def _post_processing(self, noised_data):
        df = noised_data["corruptiondata_aer"]

        # reconstruct lpop
        df["lpop"] = np.log(df["pop"])
        
        # reconstruct purb
        df["purb"] = df["nurb"] / df["pop"]

        # reconstruct p_secundario
        df["p_secundario"] = df["n_secundario"] / df["pop"]

        # reconstruct lpib02
        df["lpib02"] = np.log(df["pib_02"] / df["pop"])

        # # reconstruct lfunc_ativ
        df["lfunc_ativ"] = np.log(df["func_ativ"])

        noised_data["corruptiondata_aer"] = df
        return noised_data
    
    def vars_to_noise(self) -> list:
        return [
            "lpop",
            "purb",
            "p_secundario",
            "lpib02",
            # "gini_ipea",
            # "vereador_eleit",
            "lfunc_ativ",
        ]
    
    def other_vars(self):
        return [
            "gini_ipea", 
            "vereador_eleit",
            "pcorrupt",
            "first",
            "pref_masc",
            "pref_idade_tse",
            "pref_escola",
            "party_d1", "party_d3", "party_d4", "party_d5", "party_d6", "party_d7",
            "party_d8", "party_d9", "party_d10", "party_d11", "party_d12", "party_d13",
            "party_d14", "party_d15", "party_d16", "party_d17", "party_d18",
            "mun_novo",
            "lrec_trans",
            "p_cad_pref",
            "ENLP2000",
            "comarca",
            "sorteio1", "sorteio2", "sorteio3", "sorteio4", "sorteio5",
            "sorteio6", "sorteio7", "sorteio8", "sorteio9", "sorteio10",
            # "esample2",
            # "first_comarca", # interaction, generated
            "media2",
            # "first_media2" # interaction, generated
        ]
    
    def time_index(self):
        return None
    
    def subset_index(self):
        return "uf"
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `reelection_aer.do`: ###
        # use corruptiondata_aer.dta, replace;
        # global prefchar2 "pref_masc pref_idade_tse pref_escola party_d1  party_d3- party_d18";
        # global munichar2 "lpop purb p_secundario mun_novo lpib02 gini_ipea";
        # ...
        #--- first-corruption
        # eststo est1: areg pcorrupt first $prefchar2 $munichar2 lrec_trans  p_cad_pref vereador_eleit ENLP2000 comarca sorteio*  if esample2==1, robust abs(uf);
        # ...
        #--- judiciary-difference
        # eststo: areg pcorrupt first first_comarca $prefchar2 $munichar2 lrec_trans lfunc_ativ p_cad_pref vereador_eleit ENLP2000 comarca sorteio* if esample2==1, robust abs(uf);
        #--- first-media, media-corruption
        # eststo: areg pcorrupt first first_media2 media2 $prefchar2 $munichar2 lrec_trans lfunc_ativ p_cad_pref vereador_eleit ENLP2000 comarca sorteio* if esample2==1, robust abs(uf);
        ###
        sensitivities = {
            ### [not personal] pcorrupt: share of audited resources involving corruption
            ### [not personal] first: Mayor in first term
            ### [not personal] pref_masc: Male mayor
            ### [not personal] pref_idade_tse: Mayor's age
            ### [not personal] pref_escola: Mayor's education
            ### [not personal] party_d1, party_d3-party_d18: Mayor party dummies
            
            ### lpop: log population of municipality in 2000
            # NOTE: reconstructed lpop = log(pop)
            "pop": lambda municipality: 1,
            
            ### purb: % of population that lives in urban sector
            # purb = nurb / pop
            # NOTE: created var nurb = pop * purb
            # pop already noised
            "nurb": lambda municipality: 1,

            ### p_secundario: percentage of the population that has at least a secondary education
            # p_secundario = n_secundario / pop
            # NOTE: created var n_secundario = pop * p_secundario
            # pop already noised
            "n_secundario": lambda municipality: 1,

            ### [not personal] mun_novo: dummy new municipality
            
            ### lpib02: log GPD per capita in '02 (R$1000)
            # NOTE: using 2000 pop for denom
            # lpib02 = log(pib_02 / pop)
            # NOTE: created var pib_02 = np.exp(lpib02) * pop
            # lpib02 not personal
            # pop already noised

            ### gini_ipea
            # NOTE: not enough info for DP

            ### [not personal] lrec_trans: the amount of resources sent to the municipality expressed in logarithms
            ### [not personal] p_cad_pref: the share of the legislature that is of the same party as the mayor,

            ### vereador_eleit: the number of legislators divided by the number of voters
            # NOTE: not enough info for DP, number of voters not included

            ### [not personal] ENLP2000: 2000 ENLP (effective number of legislative parties)
            ### [not personal] comarca: region dummy
            ### [not personal] sorteio*: lottery dummies
            ### [not personal] esample2: subset dummy

            #--- judiciary-difference, first-media, media-corruption
            ### lfunc_ativ: Number of active employees (logs)
            # NOTE: created var func_ativ = exp(lfunc_ativ)
            "func_ativ": lambda municipality: 1,

            #--- judiciary-difference
            ### [not personal] first_comarca
            # gen first_comarca  = comarca*first;

            #--- first-media, media-corruption
            ### [not personal] media2: whether the municipality has a local AM radio station or newspaper
            ### [not personal] first_media2
            # gen first_media2  = media2*first;
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table4.csv")
        results.append(Result.from_esttab(
            id="first-corruption",
            table=table,
            row="first",
            col="est1",
            expected_range=Result.relative_range(-.027, tolerance=0.2)
        ))
        table = self._load_esttab(f"{self.path()}/results/table10.csv")
        results.append(Result.from_esttab(
            id="judiciary-difference",
            table=table,
            row="first_comarca",
            col="est1",
            expected_range=(0,None)
        ))
        first_media = Result.from_esttab(
            id="first-media",
            table=table,
            row="first_media2",
            col="est2",
            expected_range=(0, None)
        )
        results.append(first_media)
        results.append(Result.from_esttab(
            id="media-corruption",
            table=table,
            row="media2",
            col="est2",
            expected_range=(-first_media.est, 0)
        ))
        return results