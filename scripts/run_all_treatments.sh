TARGET=all
replicate $TARGET -x control -n 1
replicate $TARGET -x privacy -nctrl -e 0.0001 -e 0.001 -e 0.01 -e 0.1 -e 1 -e 10 -e 100 -e 1000 -m laplace -m gaussian
replicate $TARGET -x privacy_continuous -nctrl -elog 50 -m laplace -m gaussian
replicate $TARGET -x error -nctrl -a 0.001 -a 0.01 -a 0.05 -a 0.1 -a 0.2 -a 0.5 -a 0.8 -sh hudson-berger -sh morris-lysy
replicate $TARGET -x error_scaled -nctrl -a 0.001 -a 0.01 -a 0.05 -a 0.1 -a 0.2 -a 0.5 -a 0.8 -b 0.01 -b 0.1 -b 0.5 -cs est -sh hudson-berger
replicate $TARGET -x margin -nctrl -e 0.0001 -e 0.001 -e 0.01 -e 0.1 -e 1 -e 10 -e 100 -e 1000 -m gaussian -a 0.001 -a 0.01 -a 0.05 -a 0.1 -a 0.2 -a 0.5 -a 0.8 -sh hudson-berger
replicate $TARGET -x sensitivity -n 1 -nctrl -e 10000 -m laplace