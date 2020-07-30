#!/bin/bash

## Clean up any old docker containers with the same name
docker rm covidrtestimates

if ([ $1 = "build" ];); then
  ## Build the docker container
  docker build . -t covidrtestimates
else
  docker pull docker.pkg.github.com/epiforecasts/covid-rt-estimates/covidrtestimates:latest
  docker tag docker.pkg.github.com/epiforecasts/covid-rt-estimates/covidrtestimates:latest covidrtestimates
fi

