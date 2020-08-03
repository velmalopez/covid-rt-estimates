#!/bin/bash

## Run using:
## curl --fail https://raw.githubusercontent.com/epiforecasts/covid-rt-estimates/master/bin/update-via-ssh.sh > update-via-ssh.sh
## sudo bash update-via-ssh.sh path-to-key username@public-ip-of-server github-username github-pat
## Note this is not very secure and I assume there are better ways to do this
ssh -i $1 $2 GITHUB_USERNAME=$3 GITHUB_PASSWORD=$4
ssh -i $1 $2 << EOF
  sudo apt-get update -y
  sudo apt-get install -y docker.io
  sudo docker login -u $GITHUB_USERNAME -p $GITHUB_PASSWORD docker.pkg.github.com
  git clone https://github.com/epiforecasts/covid-rt-estimates.git
  cd covid-rt-estimates
  sudo bash bin/update-docker.sh "build"
  sudo bash bin/update-via-docker.sh
EOF
