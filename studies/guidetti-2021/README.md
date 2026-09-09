## Data
1. Download ZIP from https://www.openicpsr.org/openicpsr/project/136321/version/V1/view > `source.zip`.
2. `make source`.

Needs special installation of [`ivreghdfe`](https://github.com/sergiocorreia/ivreghdfe):
```stata
* Install ftools (remove program if it existed previously)
cap ado uninstall ftools
net install ftools, from("https://raw.githubusercontent.com/sergiocorreia/ftools/master/src/")

* Install reghdfe
cap ado uninstall reghdfe
net install reghdfe, from("https://raw.githubusercontent.com/sergiocorreia/reghdfe/master/src/")

* Install ivreg2, the core package
cap ado uninstall ivreg2
ssc install ivreg2

* Finally, install this package
cap ado uninstall ivreghdfe
net install ivreghdfe, from(https://raw.githubusercontent.com/sergiocorreia/ivreghdfe/master/src/)
```

## Replication
`make results`