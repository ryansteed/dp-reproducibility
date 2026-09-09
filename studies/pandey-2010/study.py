from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Pandey(Study):
    id = 'pandey-2010'

    def data_paths(self) -> dict:
        return {
            "table4": os.path.join(
                self.path(), "source/data-files", "table4.dta"
            ),
            "table4-health-committee": os.path.join(
                self.path(), "source/data-files", "table4-health-committee.dta"
            ),
            "table-5-teacher": os.path.join(
                self.path(), "source/data-files", "table-5-teacher.dta"
            ),
            "table-5-stipend": os.path.join(
                self.path(), "source/data-files", "table-5-stipend.dta"
            ),
             "table-5-infrastructure": os.path.join(
                self.path(), "source/data-files", "table-5-infrastructure.dta"
            ),
             "table-5-student-score-attendance": os.path.join(
                self.path(), "source/data-files", "table-5-student-score-attendance.dta"
            ),
            # ...
        }
    
    def vars_to_noise(self) -> list:
        # list all personal vars used in the regression
        return [
            "totpop",
            "frsc",
            "frobc",
            "density",
            "lit",
            # "tepupr",
            "toenr"
        ]
    
    def _pre_processing(self, data):
        for df in data.values():
            df["sc"] = df["frsc"] * df["totpop"]
            df["obc"] = df["frobc"] * df["totpop"]
            df["literate"] = df["lit"] * df["totpop"]
            df["area"] = (df["totpop"] / 10) / df["density"]
        return data
    
    def _post_processing(self, noised_data):
        for df in noised_data.values():
            df["frsc"] = df["sc"] / df["totpop"]
            df["frobc"] = df["obc"] / df["totpop"]
            df["lit"] = df["literate"] / df["totpop"]
            df["density"] = (df["totpop"] / 10) / df["area"]
        return noised_data

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `table-4.do`: ###
        # use table4.dta
        # ...
        #--- landlord-governance1
        # eststo gsmeet: reg  gsmeet  op dms01- dmts4 lon lat alt rain frsc frobc totpop density elec phone gpdistro lit , cluster(district)
        # ...
        #--- landlord-governance2
        # eststo ssmeet: reg  ssmeet  op dms01- dmts4 lon lat alt rain frsc frobc totpop density elec phone gpdistro lit , cluster(district)
        # ...
        #--- landlord-governance3
        # eststo ptameet: reg  ptameet op dms01- dmts4  lon lat alt rain frsc frobc totpop density elec phone gpdistro lit, cluster(district)
        # ...
        #--- landlord-governance4
        # use "table4-health-committee.dta"
        # ...
        # eststo: reg  healthcommittee  oudh dms01- dmts4   lon lat alt rain frsc frobc totpop density elec phone gpdistro lit, cluster(district)
        ###

        ### relevant regression code from `table-5.do`: ###
        # use "table-5-teacher.dta"
        # ...
        #--- landlord-teacherattend
        # eststo teacherattend: reg  tattendance tcaste tcaste2 tgen  edu toenr dissch frsc frobc   totpop op density  lit index elec phone gpdistro dms01- dmts4 lon lat alt rain, cluster(district)
        #--- landlord-teacheractivity
        # eststo activity: reg  tactivity tcaste tcaste2 tgen  edu toenr dissch frsc frobc  totpop op density  lit index  elec phone gpdistro dms01- dmts4 lon lat alt rain, cluster(district)
        # use "table-5-stipend.dta"
        # ...
        #--- landlord-stipend
        # eststo stipend: reg scholar oudh frsc frobc density totpop lit elec phone gpdistro  dms01- dmts4 lon lat alt rain if caste2==0 , cluster(district)
        # use "table-5-infrastructure.dta"
        # ...
        #--- landlord-studentinfra
        # eststo infra: reg  index frsc frobc  totpop op density lit  elec phone gpdistro dms01- dmts4 lon lat alt rain, cluster(district)
        # use "table-5-student-score-attendance.dta"
        # ...
        #--- landlord-studentscore
        # eststo meanscore: reg meanscore scaste scaste2 sgen me2 me3 fe2 fe3  tepupr frsc frobc  totpop  op density  elec phone gpdistro index  lit dms01- dmts4 lon lat alt rain, cluster(district)
        #--- landlord-studentattend
        # eststo studentattend: reg studentattendance scaste scaste2 sgen me2 me3 fe2 fe3  tepupr frsc frobc  totpop  op density  elec phone gpdistro index  lit dms01- dmts4 lon lat alt rain, cluster(district)
        
        sensitivities = {
            ### totpop: total population (appears to be in 1,000s)
            "totpop": {
                "sensitivity": lambda district: 1/1000,
                "lb": 1,
            },

            ### frsc: fraction SC population
            # assuming frsc = sc / totpop
            # NOTE created inter var sc = frsc * totpop
            "sc": lambda district: 1/1000,

            ### frobc: fraction OBC population
            # assuming frobc = obc / totpop
            # NOTE created inter var obc = frobc * totpop
            "obc": lambda district: 1/1000,

            ### lit: literacy rate
            # assuming lit = literate / totpop
            # NOTE created inter var literate = lit * totpop
            "literate": lambda district: 1/1000,

            ### density: population density, appears to be 100s of people per square km
            # assuming density = (totpop / 10) / area
            # NOTE created inter var area = (totpop / 10) / density
            # area not personal
            # totpop already noised

            #--- landlord-studentscore, landlord-studentattend
            ### tepupr: Teacher to pupil ratio
            # NOTE: neither teacher count nor pupil count given, cannot noise

            #--- landlord-teacherattend, landlord-teacheractivity
            ### toenr: Total enrollment (in 1's?)
            "toenr": lambda district: 1,

            ### [not aggregate] studentattendance: student attendance for student i in GP j and district k
            ### [not aggregate] meanscore: students test score for student i in GP j and district k
            ### [not aggregate] scholar: amount of stipend in rupees received by student i in GP j and district k
            ### [not aggregate] tattendance: Teacher attendance for teacher i in GP j and district k
            ### [not aggregate] tactivity: Teacher activity for teacher i in GP j and district k
            ### [not aggregate] tcaste: Teacher caste dummy 
            ### [not aggregate] tcaste2
            ### [not aggregate] dissch: teacher distance travelled to school?
            ### [not aggregate] me2: mother's education == 1
            ### [not aggregate] me3: mother's education == 2
            ### [not aggregate] fe2: father's education == 1
            ### [not aggregate] fe3: father's education == 2
            ### [not aggregate] tgen: Teacher gender
            ### [not aggregate] edu: Teacher education level (categorical)
            ### [not aggregate] scaste: Student caste dummy
            ### [not aggregate] scaste2
            ### [not aggregate] sgen: Student gender

            ### [not personal] index: the index of infrastructure in the sample school in GP j in district k
            ### [not personal] healthcommittee: Number of meeting in past 6 months in village: If health committee met
            ### [not personal] ptameet: Number of meeting in past 6 months in village: Parent teacher association meetings
            ### [not personal] ssmeet: Number of meeting in past 6 months in village: Village education committee meetings
            ### [not personal] gsmeet: Number of meeting in past 6 months in village: Village meetings 
            ### [not personal] dms01- dmts4: climate variables to do with soil?
            ### [not personal] lon: Longitude
            ### [not personal] lat: latitude
            ### [not personal] alt: altitude
            ### [not personal] rain: Average annual rainfall in the district
            ### [not personal] elec: wehther GP has electricty
            ### [not personal] phone: whether GP has phone
            ### [not personal] gpdistro: distance from nearest road
            ### [not personal] op: indicator for landlord district
            ### [not personal] oudh: indicator for Oudh landlord district
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table4_1.csv")
        results.append(Result.from_esttab(
            id="landlord-governance1",
            table=table,
            row="op",
            col="gsmeet",
            expected_range=(None, 0),
            est_stats={"est": "b", "se": "se"}
        ))
        results.append(Result.from_esttab(
            id="landlord-governance2",
            table=table,
            row="op",
            col="ssmeet",
            expected_range=(None, 0),
            est_stats={"est": "b", "se": "se"}
        ))
        results.append(Result.from_esttab(
            id="landlord-governance3",
            table=table,
            row="op",
            col="ptameet",
            expected_range=(None, 0),
            est_stats={"est": "b", "se": "se"}
        ))
        table = self._load_esttab(f"{self.path()}/results/table4_2.csv")
        results.append(Result.from_esttab(
            id="landlord-governance4",
            table=table,
            row="oudh",
            col="est1",
            expected_range=(None, 0),
            est_stats={"est": "b", "se": "se"}
        ))
        table = self._load_esttab(f"{self.path()}/results/table5.csv")
        results.append(Result.from_esttab(
            id="landlord-teacherattend",
            table=table,
            row="op",
            col="teacherattend",
            expected_range=(None, 0),
            est_stats={"est": "b", "se": "se"}
        ))
        results.append(Result.from_esttab(
            id="landlord-teacheractivity",
            table=table,
            row="op",
            col="activity",
            expected_range=(None, 0),
            est_stats={"est": "b", "se": "se"}
        ))
        results.append(Result.from_esttab(
            id="landlord-studentscore",
            table=table,
            row="op",
            col="meanscore",
            expected_range=(None, 0),
            est_stats={"est": "b", "se": "se"}
        ))
        results.append(Result.from_esttab(
            id="landlord-studentattend",
            table=table,
            row="op",
            col="studentattend",
            expected_range=(None, 0),
            est_stats={"est": "b", "se": "se"}
        ))
        results.append(Result.from_esttab(
            id="landlord-studentinfra",
            table=table,
            row="op",
            col="infra",
            expected_range=(None, 0),
            est_stats={"est": "b", "se": "se"}
        ))
        results.append(Result.from_esttab(
            id="landlord-stipend",
            table=table,
            row="oudh",
            col="stipend",
            expected_range=(None, 0),
            est_stats={"est": "b", "se": "se"}
        ))
        return results