
# Packages -----------------------------------------------------------------
require(EpiNow2, quietly = TRUE)
require(covidregionaldata, quietly = TRUE)
require(data.table, quietly = TRUE)
require(future, quietly = TRUE)
require(lubridate, quietly = TRUE)

# Load utils --------------------------------------------------------------

source(here::here("R", "utils.R"))

# Update delays -----------------------------------------------------------

generation_time <- readRDS(here::here("data", "generation_time.rds"))
incubation_period <- readRDS(here::here("data", "incubation_period.rds"))
reporting_delay <- readRDS(here::here("data", "onset_to_death_delay.rds"))

# Get cases  ---------------------------------------------------------------

deaths <- data.table::setDT(covidregionaldata::get_national_data(source = "ecdc"))

deaths <- deaths[country != "Cases_on_an_international_conveyance_Japan"]
deaths <- deaths[, .(region = country, date = as.Date(date), confirm = deaths_new)]
deaths <- deaths[date <= Sys.Date()]
deaths <- deaths[, .SD[date <= (max(date) - lubridate::days(3))], by = region]
deaths <- deaths[, .SD[date >= (max(date) - lubridate::weeks(8))], by = region]

data.table::setorder(deaths, date)

# Check to see if the data has been updated  ------------------------------

check_for_update(deaths, last_run = here::here("last-update", "deaths.rds"))

# Set up cores -----------------------------------------------------
no_cores <- setup_future(length(unique(deaths$region)))

# Run Rt estimation -------------------------------------------------------

regional_epinow(reported_cases = deaths,
                generation_time = generation_time,
                delays = list(incubation_period, reporting_delay),
                horizon = 14, burn_in = 14,
                non_zero_points = 7,
                samples = 2000, warmup = 500,
                cores = no_cores, chains = ifelse(no_cores <= 2, 2, no_cores),
                target_folder = "national/deaths/national",
                summary_dir = "national/deaths/summary",
                return_estimates = FALSE, verbose = FALSE)

future::plan("sequential")
