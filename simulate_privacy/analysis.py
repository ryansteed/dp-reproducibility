from sqlite_utils.db import Database
import os
import datetime
from decimal import Decimal
import sqlite3
import time
import random

from simulate_privacy.config import logger


class Result:
    def __init__(
        self,
        id: str,
        est: float, se: float,
        p: float = None,
        t: float = None,
        N: int = None,
        df_m: int = None,
        df_r: int = None,
        expected_range: tuple = None
    ) -> None:
        """
        Args:
            id (str): Descriptive ID of the result.
            est (float): Coeff value.
            se (float): Coeff standard error.
            expected_range (tuple, optional): Expected range (lower, upper) for this coefficient's 
                value to support the original study's claims. Range is exclusive. A range of (0, 0)
                implies the result should be statistically insignificantally different from zero.
                Defaults to None.
        """
        self.id = id
        self.stats = {
            "p": Decimal(str(p)) if p is not None else None,
            "t": Decimal(str(t)) if t is not None else None,
            "N": N,
            "df_m": df_m,
            "df_r": df_r
        }
        self.est = Decimal(str(est))
        self.se = Decimal(str(se))
        self.expected_range = expected_range
    
    def update_stats(self, **stats):
        self.est = stats.pop("est", self.est)
        self.se = stats.pop("se", self.se)
        self.stats.update(stats)

    def set_expected_range(self, lower, upper):
        self.expected_range = (lower, upper)
    
    @staticmethod
    def relative_range(x, tolerance, lb=None, ub=None):
        tol_lb = x - abs(x)*tolerance
        tol_ub = x + abs(x)*tolerance
        return (
            max(tol_lb, lb) if lb is not None else tol_lb, # if tolerance is below lb, use lb
            min(tol_ub, ub) if ub is not None else tol_ub, # if tolerance is above ub, use ub
        )
    
    def validate_expected_range(self):
        """Ensure the current estimate is within the expected range.
        """
        if self.expected_range is None:
            raise ValueError("Expected range is not set.")
        if self.expected_range == (0, 0):
            # insignificant --- any value could work
            return True
        if self.expected_range == (None, None):
            # any value allowed
            logger.warning(f"Expected range not set for result {self.id}. Any value will be permitted (rare).")
            return True
        lb, ub = self.expected_range
        if (lb is not None and self.est < lb) or (ub is not None and self.est > ub):
            raise ValueError(f"Estimate {self.est} is outside expected bounds {self.expected_range}.")
        return True

    def __repr__(self) -> str:
        stats_str = ", ".join([f"{k}={v}" for k, v in self.stats.items() if v is not None])
        return f"Result({self.id}, est={self.est}, se={self.se}, {stats_str}, expected_range={self.expected_range})"
    
    def to_dict(self):
        if self.expected_range is None:
            raise ValueError("To write to dict, expected range must be set.")
        return dict(
            result_id=self.id,
            est=self.est,
            se=self.se,
            expected_lb=self.expected_range[0],
            expected_ub=self.expected_range[1],
            **self.stats
        )

    def __eq__(self, other) -> bool:
        if not isinstance(other, Result):
            return False
        if self.id != other.id:
            logger.debug(f"IDs do not match: {self.id} != {other.id}")
            return False
        precision = lambda x, y: max(x.as_tuple().exponent, y.as_tuple().exponent)
        if abs(self.est - other.est) > 10**precision(self.est, other.est):
            logger.debug(f"Estimates do not match: {self.est} != {other.est} (diff: {abs(self.est - other.est)})")
            return False
        if abs(self.se - other.se) > 10**precision(self.se, other.se):
            logger.debug(f"Standard errors do not match: {self.se} != {other.se} (diff: {abs(self.se - other.se)})")
            return False
        return True

    # def __hash__(self):
    #     return hash((self.id, round(self.est, -self.est.as_tuple().exponent), round(self.se, -self.se.as_tuple().exponent)))

    @classmethod
    def from_esttab(cls, id, table, row, col, est_stats={}, **kwargs):
        stats = {}
        est_stat_map = {"est": "b", "se": "se", "p": "p", "t": "t"}
        est_stat_map.update(est_stats)
        for key, stat in est_stat_map.items():
            stats[key] = table.loc[row, f"{col}_{stat}"]
        for stat in ["N", "df_m", "df_r"]:
            stats[stat] = table.loc[stat, f"{col}_{est_stat_map['est']}"]
        return cls(
            id=id,
            **stats,
            **kwargs
        )


def _tracer(sql, params):
        # logger.debug("SQL> {} - params: {}".format(sql, params))
        pass


class TableManager:
    pk = NotImplemented

    def __init__(self, name: str = "results", transform: bool = False) -> None:
        if name == "" or name is None:
            name = "results"
        base_path = os.path.dirname(os.path.realpath(__file__))
        path_db = os.path.join(base_path, '..', 'results', 'experiments', f'{name}.db')
        self.dbc = sqlite3.connect(path_db, timeout=30)
        logger.debug(f"Opened database manager connected to {path_db}.{self._table_id()}")
        self.db = Database(self.dbc, tracer=_tracer)
        if transform:
            self.db.enable_wal() # write-ahead logging for better concurrency
            self.db.execute("PRAGMA journal_size_limit = 1000000000;") # 1 GB
            self.db.execute("PRAGMA synchronous = NORMAL;")
            # drop old tables from `transform` option, if still around
            old_transform_tables = [r["name"] for r in self.db.query(f"""
                SELECT name FROM sqlite_master WHERE type = 'table' and name LIKE '{self._table_id()}_new_%';
            """)]
            for tbl in old_transform_tables:
                self.db.execute(f"""
                    DROP TABLE IF EXISTS {tbl};
                """)
            self.create_table()
        self.table = self.db.table(self._table_id())

    def vacuum(self):
        self.db.execute("VACUUM;")
        self.dbc.commit()

    def create_table(self):
        raise NotImplementedError
    
    def _table_id(self):
        raise NotImplementedError

    def upsert(self, **record):
        record = self._clean_record(record)
        self.table.insert(record, pk=self.pk, replace=True)
        logger.debug(f"Upserted {record}")
        self.dbc.commit()
    
    def upsert_all(self, records):
        records = [self._clean_record(r) for r in records]
        # logger.debug(f"Upserting records: {records}")
        try:
            self.table.insert_all(records, pk=self.pk, replace=True)
        except sqlite3.OperationalError as e:
            time.sleep(random.random() * 10 + 1)
            self.table.insert_all(records, pk=self.pk, replace=True)
        logger.debug(f"Upserted {len(records)} records")
        self.dbc.commit()

    def _clean_record(self, record):
        for k in self.pk:
            if k not in record.keys():
                record[k] = str(None)
        return record
    
    def clear_experiments(self, experiment_records):
        self.table.delete_where(
            "({}) IN ({})".format(
                ",".join(ExperimentsDB.pk),
                ",".join(["('{}','{}','{}','{}')".format(
                    *[r[k] for k in ExperimentsDB.pk]
                ) for r in experiment_records])
            )
        )
        self.dbc.commit()  # for some reason this is not automatically called


class ExperimentsDB(TableManager):
    pk = [
        'study_id',
        'epsilon_str',
        'mechanism_str',
        'a_str',
        'cscale_str',
        'b_str',
        'shrink_str',
        'imputations_str',
        'experiment_id'
    ]

    def _table_id(self):
        return "experiments"
    
    def create_table(self):
        logger.debug(f"Creating table {self._table_id()}")
        self.db[self._table_id()].create({
                "time": datetime.datetime,
                ## EXPERIMENT KEY
                **{k: str for k in ExperimentsDB.pk},
                ##
                "rho": float
            },
            pk=self.pk,
            not_null=set(("time", "study_id")),
            defaults={
                "time": "CURRENT_TIMESTAMP"
            },
            transform=True
        )


class ResultsDB(TableManager):
    pk = ExperimentsDB.pk + ['result_id', 'sim_id']
    
    def _table_id(self):
        return "results"
    
    def create_table(self):
        self.db[self._table_id()].create({
                "time": datetime.datetime,
                ## EXPERIMENT KEY
                **{k: str for k in ExperimentsDB.pk},
                ##
                ## RESULT KEY
                "result_id": str,
                "sim_id": int,
                ##
                "est": float,
                "se": float,
                "expected_lb": float,
                "expected_ub": float,
                "t": float,
                "p": float,
                "N": int,
                "df_m": int,
                "df_r": int
            },
            pk=self.pk,
            foreign_keys=[
                (k, "experiments", k) for k in ExperimentsDB.pk
            ],
            not_null=set(("time", "study_id", "result_id", "sim_id")),
            defaults={
                "time": "CURRENT_TIMESTAMP"
            },
            transform=True
        )


class NoiseDB(TableManager):
    pk = ExperimentsDB.pk + ['variable', 'sim_id', 'dataset']

    def _table_id(self):
        return "noise"
    
    def clear(self, **keys):
        key = ExperimentsDB.pk + ['sim_id', 'dataset']
        self.table.delete_where(
            "({}) IN ({})".format(
                ",".join(key),
                ",".join(["('{}','{}','{}','{}')".format(
                    *[r[k] for k in key]
                ) for r in keys])
            )
        )
        self.dbc.commit()  # for some reason this is not automatically called
    
    def create_table(self):
        self.db[self._table_id()].create({
                "time": datetime.datetime,
                ## EXPERIMENT KEY
                **{k: str for k in ExperimentsDB.pk},
                ##
                "sim_id": int,
                "variable": str,
                "dataset": str,
                "rmsd": float,
                "original_mean": float,
                "original_std": float,
                "original_min": float,
                "original_max": float,
                "rmsd_norm": float
            },
            pk=self.pk,
            foreign_keys=[
                (k, "experiments", k) for k in ExperimentsDB.pk
            ] + [
                ("sim_id", "results", "sim_id")
            ],
            not_null=set(("time", "study_id", "sim_id", "variable")),
            defaults={
                "time": "CURRENT_TIMESTAMP"
            },
            transform=True
        )


class SensitivityDB(TableManager):
    pk = ("experiment_id", "study_id", "variable", "dataset")

    def _table_id(self):
        return "sensitivity"
    
    def create_table(self):
        self.db[self._table_id()].create({
                "time": datetime.datetime,
                ## PRIMARY KEY
                "study_id": str,
                "experiment_id": str,
                "variable": str,
                "dataset": str,
                ##
                "sensitivity": float,
                "original_mean": float,
                "original_std": float,
                "original_min": float,
                "original_max": float
            },
            pk=self.pk,
            foreign_keys=[
                ("study_id", "experiments", "study_id"),
                ("experiment_id", "experiments", "experiment_id")
            ],
            not_null=set(("time", "study_id", "variable", "dataset")),
            defaults={
                "time": "CURRENT_TIMESTAMP"
            },
            transform=True
        )
