import click
import os

from simulate_privacy.experiment import ExperimentHandler
from simulate_privacy.config import LogManager

from loguru import logger


@click.group(chain=True)
def cli():
    pass


@cli.command('replicate')
@click.argument('study_id')
@click.option(
    '-e', '--epsilon',
    type=float, multiple=True, default=[],
    help='Epsilon value for differential privacy'
)
@click.option(
    '-elog', '--epsilon-log',
    type=int, default=None,
    help='Number of epsilon points on a log scale'
)
@click.option(
    '-m', '--mechanism',
    type=str, multiple=True, default=["gaussian"],
    help='Privacy mechanism for differential privacy'
)
@click.option(
    '-cs', '--cscale',
    type=str, multiple=True, default=["static"],
    help="Method for scaling coefficients of variation (one of `est`, `n`)."
)
@click.option(
    '-a',
    type=float, multiple=True, default=[],
    help='Proportion for coefficients of variation.'
)
@click.option(
    '-b',
    type=float, multiple=True, default=[],
    help='Power parameter for scaled coefficients of variation. Default 1/2. Reasonable values <1.'
)
@click.option(
    '-sh', '--shrink',
    type=str, multiple=True, default=[None],
    help='Shrinkage construction for error distribution.'
)
@click.option(
    '-mo', '--imputations',
    type=int, multiple=True, default=[],
    help='Number of imputations for multiple overimputation.'
)
@click.option(
    '-n', '--num-runs',
    type=int, default=10,
    help='Number of runs per noise mechanism'
)
@click.option(
    '-x', '--experiment-id',
    type=str, default=None,
    help='Experiment ID to tag runs'
)
@click.option('-c', '--from-cache', is_flag=True)
@click.option('--save-to-cache', is_flag=True)
@click.option('-v', '--verbose', is_flag=True)
@click.option('-q', '--quiet', is_flag=True)
@click.option('-nctrl', '--no-control', is_flag=True)
def replicate(
    study_id,
    epsilon, mechanism, cscale, a, b, shrink, imputations,
    verbose, quiet,
    **kwargs
):
    if verbose:
        logger.info("Logger set to DEBUG")
        os.environ["LOG_LEVEL"] = "DEBUG"
    elif quiet:
        os.environ["LOG_LEVEL"] = "ERROR"
    else:
        os.environ["LOG_LEVEL"] = "INFO"
    LogManager.setup_logger()
    _replicate(
        study_id,
        epsilons=list(epsilon),
        mechanisms=list(mechanism),
        cscales=list(cscale),
        aparams=list(a),
        bparams=list(b),
        shrinks=list(shrink),
        imputations=list(imputations),
        keep_debug_folder=verbose,
        **kwargs
    )   # pass to worker fxn to avoid click context obj


def _replicate(
        study_id: str,
        num_runs: int = 10,
        from_cache: bool = False,
        save_to_cache: bool = False,
        keep_debug_folder: bool = False,
        experiment_id: str = "",
        **treatment_kwargs
    ):

    handler = ExperimentHandler(experiment_id, study_id, **treatment_kwargs)
    return handler.run(
        num_runs,
        from_cache=from_cache,
        save_to_cache=save_to_cache,
        keep_debug_folder=keep_debug_folder
    )


if __name__ == "__main__":
    cli()
