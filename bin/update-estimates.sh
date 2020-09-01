#!/bin/bash


# Remove last update flag
rm last-update/update-complete

# Array of all targets to update
declare -a targets=(
  "R/update-cases.R"
  "R/update-deaths.R"
)

# Run each estimat in turn
for target in ${targets[@]}; do
  printf "\tRunning update for: %s \n" $target
  Rscript  $target
done

# Run all stable countries
printf "Run for all regional locations"
Rscript R/run-region-updates.R

# Add update complete flag
touch last-update/update-complete