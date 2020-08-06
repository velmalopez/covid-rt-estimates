#!/bin/bash

ssh -i $1 $2 GITHUB_USERNAME=$3 GITHUB_PASSWORD=$4 "sudo apt-get update -y && \
  sudo apt-get install -y docker.io && \
  echo "$GITHUB_PASSWORD" | sudo docker login docker.pkg.github.com --username $GITHUB_USERNAME --password-stdin  && \
  git clone https://github.com/epiforecasts/covid-rt-estimates.git && \
  cd covid-rt-estimates && \
  sudo bash bin/update-docker.sh "build" && \
  sudo bash bin/update-via-docker.sh"
  
  

