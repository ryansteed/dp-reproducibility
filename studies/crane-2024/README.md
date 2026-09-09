## Data
1. Download ZIP from https://www.openicpsr.org/openicpsr/project/183163/version/V2/view > `source.zip`.
2. `make source`.

## Replication
Not running SAS pre-processing scripts; just using intermediate .do files.

Changes to code:
- Changed all `\\` to `/` for Unix.

Original prints p-values, but changed to standard errors. (Also checked manually that p-values matched.)