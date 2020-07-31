# Packages -----------------------------------------------------------------
require(EpiNow2)
require(covidregionaldata)
require(data.table)
require(future)
require(lubridate)


# Load utils --------------------------------------------------------------

source(here::here("R", "utils.R"))

# Update delays -----------------------------------------------------------

generation_time <- readRDS(here::here("data", "generation_time.rds"))
incubation_period <- readRDS(here::here("data", "incubation_period.rds"))
reporting_delay <- readRDS(here::here("data", "onset_to_admission_delay.rds"))

# Get cases  ---------------------------------------------------------------

cases <- data.table::setDT(covidregionaldata::get_regional_data(country = "Germany"))

cases <- clean_regional_data(cases[, region := bundesland])

# Check to see if the data has been updated  ------------------------------

check_for_update(cases, last_run = here::here("last-update", "germany.rds"))

# Set up cores -----------------------------------------------------

no_cores <- setup_future(length(unique(cases$region)))

# Run Rt estimation -------------------------------------------------------

regional_epinow_with_settings(reported_cases = cases,
                generation_time = generation_time,
                delays = list(incubation_period, reporting_delay),
                no_cores = no_cores,
                target_dir = "subnational/germany/cases/national",
                summary_dir = "subnational/germany/cases/summary")
