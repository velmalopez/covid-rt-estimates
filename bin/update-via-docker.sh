#!/bin/bash

## Make a results directory
mkdir results

## Update estimates in newly built docker container
## This will use all cores available to docker by default
sudo docker run --rm --user rstudio --mount type=bind,source=$(pwd),target=/home/rstudio/covid-rt-estimates --name covidrtestimates covidrtestimates /bin/bash bin/update-estimates.sh

