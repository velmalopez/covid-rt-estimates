#!/bin/bash

## Run using:
## curl --fail https://raw.githubusercontent.com/epiforecasts/covid-rt-estimates/master/bin/update-via-ssh.sh > update-via-ssh.sh
## sudo bash update-via-ssh.sh path-to-key username@public-ip-of-server github-username github-pat
## Note this is not very secure and I assume there are better ways to do this
ssh -i $1 $2 GITHUB_USERNAME=$3 GITHUB_PASSWORD=$4 "sudo apt-get update -y && \
  sudo apt-get install -y docker.io && \
  # The docker login step here is failing - current work around is to ssh and docker login first
  #echo "$GITHUB_PASSWORD" | sudo docker login --username $GITHUB_USERNAME --password-stdin docker.pkg.github.com && \
  git clone https://github.com/epiforecasts/covid-rt-estimates.git && \
  cd covid-rt-estimates && \
  sudo bash bin/update-docker.sh "build" && \
  sudo bash bin/update-via-docker.sh"
