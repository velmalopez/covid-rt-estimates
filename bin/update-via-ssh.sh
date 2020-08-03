#!/bin/bash

## Run using:
## sudo bash <(curl -s https://raw.githubusercontent.com/epiforecasts/covid-rt-estimates/master/bin/update-via-ssh.sh) path-to-key username@public-ip-of-server
ssh -i $1 $2 << EOF
  sudo apt-get update -y
  sudo apt-get install -y docker.io
  sudo docker login docker.pkg.github.com
  git clone https://github.com/epiforecasts/covid-rt-estimates.git
  cd covid-rt-estimates
  sudo bash bin/update-docker.sh "build"
  sudo bash bin/update-via-docker.sh
EOF
