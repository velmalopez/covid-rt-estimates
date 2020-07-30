#!/bin/bash

## Clean up any old docker containers with the same name
docker rm covidrtestimates

## Build the docker container
docker build . -t covidrtestimates