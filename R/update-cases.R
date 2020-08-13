# Packages -----------------------------------------------------------------
require(EpiNow2, quietly = TRUE)
require(covidregionaldata, quietly = TRUE)
require(data.table, quietly = TRUE)
require(future, quietly = TRUE)
require(here, quietly = TRUE)
require(lubridate, quietly = TRUE)
require(futile.logger, quietly = TRUE)

# Load utils --------------------------------------------------------------

source(here::here("R", "utils.R"))

# Update delays -----------------------------------------------------------

generation_time <- readRDS(here::here("data", "generation_time.rds"))
incubation_period <- readRDS(here::here("data", "incubation_period.rds"))
reporting_delay <- readRDS(here::here("data", "onset_to_admission_delay.rds"))

# Set up logging ----------------------------------------------------------

setup_log()

# Get cases  ---------------------------------------------------------------

cases <- data.table::setDT(covidregionaldata::get_national_data(source = "ecdc"))

cases <- cases[, .(region = country, date = as.Date(date), confirm = cases_new)]
cases <- cases[date <= Sys.Date()]
cases <- cases[, .SD[date <= (max(date) - lubridate::days(3))], by = region]
cases <- cases[, .SD[date >= (max(date) - lubridate::weeks(12))], by = region]
data.table::setorder(cases, date)


# Check to see if the data has been updated  ------------------------------

check_for_update(cases, last_run = here::here("last-update", "cases.rds"),
                 data = "cases")

# # Set up cores -----------------------------------------------------

no_cores <- setup_future(length(unique(cases$region)))

# Run Rt estimation -------------------------------------------------------

regional_epinow(reported_cases = cases,
                generation_time = generation_time,
                delays = list(incubation_period, reporting_delay),
                horizon = 14, burn_in = 14,
                non_zero_points = 14,
                samples = 2000, warmup = 500,
                cores = no_cores, chains = 2,
                target_folder = "national/cases/national",
                summary_dir = "national/cases/summary",
                all_regions_summary = FALSE,
                region_scale = "Country",
                return_estimates = FALSE, verbose = FALSE)

future::plan("sequential")
