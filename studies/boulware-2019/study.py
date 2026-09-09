from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import os


class Boulware(Study):
    id = 'boulware-2019'

    def data_paths(self) -> dict:
        return {
            "bk-panel-section-data": os.path.join(
                self.path(), "source","data", "bk-panel-section-data.dta"
            ),
            "bk-cross-section-data": os.path.join(
                self.path(), "source","data", "bk-cross-section-data.dta"
            )
        }

    def _pre_processing(self, data: Dict[str, pd.DataFrame]) -> Dict:
        for name in data.keys():
            df = data[name].copy()
            if name == "bk-cross-section-data":
                df["unemp1"] = df["punemp1"] * df["lf1"]
                df["unemp4"] = df["punemp4"] * df["lf4"]
            df["unemp7"] = df["punemp7"] * df["lf7"]
            df["unemp13"] = df["punemp13"] * df["lf13"]
            data[name] = df
        return data
    
    def _post_processing(self, noised_data) -> pd.DataFrame:
        for name, df in noised_data.items():
            if name == "bk-cross-section-data":
                df["punemp1"] = df["unemp1"] / df["lf1"]
                df["punemp4"] = df["unemp4"] / df["lf4"]
            df["punemp7"] = df["unemp7"] / df["lf7"]
            df["punemp13"] = df["unemp13"] / df["lf13"]
            noised_data[name] = df
        return noised_data
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `bk-panel-replication.do`, `bk-cross-section`: ###
        ## TABLE 1
        # use "bk-panel-section-data"
        # gen race_rate = race/(lf7+ lf13)
        # ...
        # * Regression (1)
        # eststo: xtreg race_rate punemp1, fe					
        # * Regression (2)
        # eststo: xtreg race_rate punemp4 punemp7 punemp13,fe

        ## TABLE 2
        # use "bk-cross-section-data"
        # gen race_rate = race/(lf7+ lf13)  
        # gen wht_lf_share = lf4/lf1
        # gen blk_lf_share = lf7/lf1
        # gen hisp_lf_share = lf13/lf1
        # * generate "blue collar" employment shares
        # gen blkm_tot  = BLKM1+BLKM1_2+BLKM2+BLKM3+BLKM4+BLKM5+BLKM6+BLKM7+BLKM8+BLKM9
        # gen blkf_tot  = BLKF1+BLKF1_2+BLKF2+BLKF3+BLKF4+BLKF5+BLKF6+BLKF7+BLKF8+BLKF9
        # gen blk_blue  = BLKM5+BLKM6+BLKM7+BLKM8+BLKM9+BLKF5+BLKF6+BLKF7+BLKF8+BLKF9
        # gen blk_blue_shr = blk_blue/(blkm_tot + blkf_tot)
        # gen hspm_tot  = HISPM1+HISPM1_2+HISPM2+HISPM3+HISPM4+HISPM5+HISPM6+HISPM7+HISPM8+HISPM9
        # gen hspf_tot  = HISPF1+HISPF1_2+HISPF2+HISPF3+HISPF4+HISPF5+HISPF6+HISPF7+HISPF8+HISPF9
        # gen hsp_blue  = HISPM5+HISPM6+HISPM7+HISPM8+HISPM9+HISPF5+HISPF6+HISPF7+HISPF8+HISPF9
        # gen hsp_blue_shr = hsp_blue/(hspm_tot + hspf_tot)
        # gen whm_tot  = WHM1+WHM1_2+WHM2+WHM3+WHM4+WHM5+WHM6+WHM7+WHM8+WHM9
        # gen whf_tot  = WHF1+WHF1_2+WHF2+WHF3+WHF4+WHF5+WHF6+WHF7+WHF8+WHF9
        # gen wh_blue  = WHM5+WHM6+WHM7+WHM8+WHM9+WHF5+WHF6+WHF7+WHF8+WHF9
        # gen wh_blue_shr = wh_blue/(whm_tot + whf_tot)
        # gen blue_share = (blk_blue + wh_blue + hsp_blue)/(blkm_tot + blkf_tot + /// 
        #                 whm_tot + whf_tot + hspm_tot + hspf_tot)
        # * Regression (1)
        # eststo: regress race_rate blk_lf_share hisp_lf_share blue_share punemp4 punemp7 punemp13 confederate
        # * Regression (2)
        # eststo: regress race_rate blk_lf_share hisp_lf_share blue_share punemp13
        ###
        vars_to_noise = {
            ### race_rate: "claims/1000"
            # gen race_rate = race/(lf7+ lf13)
            # race: Number of race-based discrimination charges
            "race": lambda state: 1,
            # lf7: Black or African American --- in thousands of workers
            "lf7": lambda state: 1/1000,
            # lf13: Hispanic or Latino ethnicity --- in thousands of workers
            "lf13": lambda state: 1/1000,

            ### punemp1: "Overall unemployment rate"
            # assuming punemp1 = unemployed / lf1, since lf1 is the total labor force
            # created inter var unemp1 = punemp1 * lf1
            # NOTE: LF1 only available for Table 2 data; left invariant for Table 1
            "lf1": lambda state: 1,
            "unemp1": lambda state: 1,
            ### punemp4: "White unemployment rate"
            # created inter var unemp4 = punemp4 * lf4
            # NOTE: LF4 only available for Table 2 data; left invariant for Table 1
            "lf4": lambda state: 1,
            "unemp4": lambda state: 1,
            ### punemp7: "Black unemployment rate"
            # created inter var unemp7 = punemp7 * lf7
            "lf7": lambda state: 1,
            "unemp7": lambda state: 1,
            ### punemp13: "Hispanic unemployment rate"
            # created inter var unemp13 = punemp13 * lf13
            "lf13": lambda state: 1,
            "unemp13": lambda state: 1,

            ## bk-cross-section-data
            ### race_rate: "claims/1000"
            # covered above

            ### blk_lf_share: "Black share in labor force"
            # gen blk_lf_share = lf7/lf1
            # covered above

            ### hisp_lf_share: "Hispanic share in labor force"
            # gen hisp_lf_share = lf13/lf1
            # covered above
            
            ### blue_share: "Share of blue collar workers"
            # gen blue_share = (blk_blue + wh_blue + hsp_blue)/(blkm_tot + blkf_tot + /// 
            #     whm_tot + whf_tot + hspm_tot + hspf_tot)
            # blk_blue  = BLKM5+BLKM6+BLKM7+BLKM8+BLKM9+BLKF5+BLKF6+BLKF7+BLKF8+BLKF9
            # these are all counts in thousands
            "BLKM5": lambda state: 1/1000,
            "BLKM6": lambda state: 1/1000,
            "BLKM7": lambda state: 1/1000,
            "BLKM8": lambda state: 1/1000,
            "BLKM9": lambda state: 1/1000,
            "BLKF5": lambda state: 1/1000,
            "BLKF6": lambda state: 1/1000,
            "BLKF7": lambda state: 1/1000,
            "BLKF8": lambda state: 1/1000,
            "BLKF9": lambda state: 1/1000,
            # wh_blue  = WHM5+WHM6+WHM7+WHM8+WHM9+WHF5+WHF6+WHF7+WHF8+WHF9
            "WHM5": lambda state: 1/1000,
            "WHM6": lambda state: 1/1000,
            "WHM7": lambda state: 1/1000,
            "WHM8": lambda state: 1/1000,
            "WHM9": lambda state: 1/1000,
            "WHF5": lambda state: 1/1000,
            "WHF6": lambda state: 1/1000,
            "WHF7": lambda state: 1/1000,
            "WHF8": lambda state: 1/1000,
            "WHF9": lambda state: 1/1000,
            # hsp_blue  = HISPM5+HISPM6+HISPM7+HISPM8+HISPM9+HISPF5+HISPF6+HISPF7+HISPF8+HISPF9
            "HISPM5": lambda state: 1/1000,
            "HISPM6": lambda state: 1/1000,
            "HISPM7": lambda state: 1/1000,
            "HISPM8": lambda state: 1/1000,
            "HISPM9": lambda state: 1/1000,
            "HISPF5": lambda state: 1/1000,
            "HISPF6": lambda state: 1/1000,
            "HISPF7": lambda state: 1/1000,
            "HISPF8": lambda state: 1/1000,
            "HISPF9": lambda state: 1/1000,
            # blkm_tot  = BLKM1+BLKM1_2+BLKM2+BLKM3+BLKM4+BLKM5+BLKM6+BLKM7+BLKM8+BLKM9
            "BLKM1": lambda state: 1/1000,
            "BLKM1_2": lambda state: 1/1000,
            "BLKM2": lambda state: 1/1000,
            "BLKM3": lambda state: 1/1000,
            "BLKM4": lambda state: 1/1000,
            # blkf_tot  = BLKF1+BLKF1_2+BLKF2+BLKF3+BLKF4+BLKF5+BLKF6+BLKF7+BLKF8+BLKF9
            "BLKF1": lambda state: 1/1000,
            "BLKF1_2": lambda state: 1/1000,
            "BLKF2": lambda state: 1/1000,
            "BLKF3": lambda state: 1/1000,
            "BLKF4": lambda state: 1/1000,
            # whm_tot  = WHM1+WHM1_2+WHM2+WHM3+WHM4+WHM5+WHM6+WHM7+WHM8+WHM9
            "WHM1": lambda state: 1/1000,
            "WHM1_2": lambda state: 1/1000,
            "WHM2": lambda state: 1/1000,
            "WHM3": lambda state: 1/1000,
            "WHM4": lambda state: 1/1000,
            # whf_tot  = WHF1+WHF1_2+WHF2+WHF3+WHF4+WHF5+WHF6+WHF7+WHF8+WHF9
            "WHF1": lambda state: 1/1000,
            "WHF1_2": lambda state: 1/1000,
            "WHF2": lambda state: 1/1000,
            "WHF3": lambda state: 1/1000,
            "WHF4": lambda state: 1/1000,
            # hspm_tot  = HISPM1+HISPM1_2+HISPM2+HISPM3+HISPM4+HISPM5+HISPM6+HISPM7+HISPM8+HISPM9
            "HISPM1": lambda state: 1/1000,
            "HISPM1_2": lambda state: 1/1000,
            "HISPM2": lambda state: 1/1000,
            "HISPM3": lambda state: 1/1000,
            "HISPM4": lambda state: 1/1000,
            # hspf_tot  = HISPF1+HISPF1_2+HISPF2+HISPF3+HISPF4+HISPF5+HISPF6+HISPF7+HISPF8+HISPF9
            "HISPF1": lambda state: 1/1000,
            "HISPF1_2": lambda state: 1/1000,
            "HISPF2": lambda state: 1/1000,
            "HISPF3": lambda state: 1/1000,
            "HISPF4": lambda state: 1/1000,

            ### punemp4: "White unemployment rate"
            # covered above
            ### punemp7: "Black unemployment rate"
            # covered above
            ### punemp13: "Hispanic unemployment rate"
            # covered above
        }
        return vars_to_noise
    
    def vars_to_noise(self) -> list:
        ### vars to noise
        ## bk-panel-section-data
        # race_rate: "claims/1000"
        # punemp1: "Overall unemployment rate"
        # punemp4: "White unemployment rate"
        # punemp7: "Black unemployment rate"
        # punemp13: "Hispanic unemployment rate"

        ## bk-cross-section-data
        # race_rate: Number of race-based discrimination charges / 1000
        # blk_lf_share: "Black share in labor force"
        # hisp_lf_share: "Hispanic share in labor force"
        # blue_share: "Share of blue collar workers"
        # punemp4: "White unemployment rate"
        # punemp7: "Black unemployment rate"
        # punemp13: "Hispanic unemployment rate"
        # [not private] confederate --- dummy for confederate states
        ###
        return [
            "race_rate",
            # "punemp1", # left invariant for table 1
            # "punemp4", # left invariant for table 1
            "punemp7",
            "punemp13",
            "blk_lf_share",
            "hisp_lf_share",
            "blue_share"
        ]

    def extract_results(self) -> list[Result]:
        results = []
        table1 = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="unemp-dis-overall",
            table=table1,
            row="punemp1",
            col="est1",
            expected_range=(0, None)
        ))
        results.append(Result.from_esttab(
            id="unemp-dis-black",
            table=table1,
            row="punemp7",
            col="est2",
            expected_range=(0, None)
        ))
        results.append(Result.from_esttab(
            id="unemp-dis-hisp",
            table=table1,
            row="punemp13",
            col="est2",
            expected_range=(0, None)
        ))
        table2 = self._load_esttab(f"{self.path()}/results/table2.csv")
        results.append(Result.from_esttab(
            id="blueshare-dis",
            table=table2,
            row="blue_share",
            col="est1",
            expected_range=(0, None)
        ))
        results.append(Result.from_esttab(
            id="blackshare-dis",
            table=table2,
            row="blk_lf_share",
            col="est1",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="hispshare-dis",
            table=table2,
            row="hisp_lf_share",
            col="est1",
            expected_range=(None, 0)
        ))
        return results