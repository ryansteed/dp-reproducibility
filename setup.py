from distutils.core import setup

setup(
    name='simulate_privacy',
    version='1.0',
    packages=['simulate_privacy'],
    # license='Creative Commons Attribution-Noncommercial-Share Alike license',
    long_description=open('README.md').read(),
    install_requires=[
        'click',
        'pandas',
        'diffprivlib',
        'opendp==0.12.0',
        'pytest',
        'tqdm',
        'sqlite-utils',
        'loguru',
        'pyreadr'
    ],
    entry_points={
        'console_scripts': [
            'simulate_privacy = simulate_privacy.api:cli',
            'replicate = simulate_privacy.api:replicate'
        ]
    }
)