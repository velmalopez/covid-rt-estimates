#!/bin/bash

## Make a results directory
mkdir results

## Update estimates in newly built docker container
## This will use all cores available to docker by default
docker run --rm --user rstudio --mount type=bind,source=$(pwd)/results,target=/home/covidrtestimates covidrtestimates /bin/bash bin/update-estimates.sh

## Move newly produced results and clean up
mv -f results/national national
mv -f results/subnational subnational
mv -f results/last-update
rm -r -f results
