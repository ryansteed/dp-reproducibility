import pathlib
from loguru import logger
from tqdm import tqdm
import sys
import os
import stata_setup
import yaml

root = pathlib.Path(__file__).parent.parent.resolve()

#--- CONFIG VARS
def load_config():
    with open(os.path.join(root, 'config.yml')) as f:
        return yaml.safe_load(f)
#---


#--- LOGGING
if os.environ.get("LOG_LEVEL") is None:
    os.environ["LOG_LEVEL"] = "INFO"


class LogManager:
    summary_log_name = "summary"
    log_dir = os.path.join(root, 'logs')

    @staticmethod
    def add_summary_logger(id: str):
        summary_log_dir = os.path.join(LogManager.log_dir, 'summaries')
        if not os.path.exists(summary_log_dir):
            os.makedirs(summary_log_dir)
        logger.add(**{
            "sink": os.path.join(summary_log_dir, f"{id}.log"),
            "format": LogManager.fmt(),
            "colorize": False,
            "level": "INFO",
            "rotation": "50 MB",
            "filter": lambda record: record["extra"].get(LogManager.summary_log_name, False)
        })
    
    @staticmethod
    def fmt():
        return (
            '<green>{time:DD-MM-YY HH:mm:ss}</green> <level>{level}></level> {message}'
            if os.environ["LOG_LEVEL"] == "INFO" else
            '<green>{time:DD-MM-YY HH:mm:ss}</green> <blue>[{name}:{line}]</blue> <level>{level}></level> {message}'
        )

    @staticmethod
    def setup_logger():
        logger.remove()
        if not os.path.exists(LogManager.log_dir):
            os.makedirs(LogManager.log_dir)
        logger.configure(handlers=[
            {
                "sink": lambda msg: tqdm.write(msg, end=""),
                "format": LogManager.fmt(),
                "colorize": True,
                "level": os.environ["LOG_LEVEL"]
            },
            {
                "sink": os.path.join(LogManager.log_dir, 'main.log'),
                "format": LogManager.fmt(),
                "colorize": False,
                "level": "DEBUG",
                "rotation": "50 MB"
            }
        ])
        # add the main summary logger; persists across runs
        LogManager.add_summary_logger(LogManager.summary_log_name)
# LogManager.setup_logger()
#---

#--- STATA
def setup_stata():
    stata_setup.config(os.environ["STATA_DIR"], "mp")
#---