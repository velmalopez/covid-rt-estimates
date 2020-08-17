# Packages -----------------------------------------------------------------
require(EpiNow2, quietly = TRUE)
require(covidregionaldata, quietly = TRUE)
require(data.table, quietly = TRUE)
require(future, quietly = TRUE)
require(lubridate, quietly = TRUE)

# Load utils --------------------------------------------------------------

source(here::here("R", "utils.R"))


#' update.regional
#'
#' @description Processes regional data in an abstract fashion to reduce code duplication
#' @param region_name String, name of region, used for filepaths and filenames
#' @param covid_regional_data_identifier String, region identifier used by covidregionaldata to get the data #todo audit which countries this differs from name and standardise
#' @param case_modifier_function Function, passed the cases, should return the cases. Method of modifying the returned data for a specific region if needed
#' @param generation_time optional overrides for the loaded rds file. If present won't be reloaded from disk.
#' @param incubation_period optional overrides for the loaded rds file. If present won't be reloaded from disk.
#' @param reporting_delay optional overrides for the loaded rds file. If present won't be reloaded from disk.
#' @param cases_subregion_source string, optional specification of where to get the list of regions from the cases dataset
#' @param region_scale string, specify the region scale to epinow
update_regional <- function(region_name, covid_regional_data_identifier, case_modifier_function = NULL, generation_time = NULL, incubation_period = NULL, reporting_delay = NULL, cases_subregion_source = NULL, region_scale = NULL) {
  futile.logger::flog.info("Processing regional dataset for %s", region_name)
  # setting debug level to trace whilst still in beta. #ToDo: remove this line once production ready
  futile.logger::flog.threshold(futile.logger::TRACE)

  # Update delays -----------------------------------------------------------

  if (is.null(generation_time)) {
    generation_time <- readRDS(here::here("data", "generation_time.rds"))
  }
  if (is.null(incubation_period)) {
    incubation_period <- readRDS(here::here("data", "incubation_period.rds"))
  }
  if (is.null(reporting_delay)) {
    reporting_delay <- readRDS(here::here("data", "onset_to_admission_delay.rds"))
  }

  # Get cases  ---------------------------------------------------------------

  futile.logger::flog.trace("Getting regional data")
  cases <- data.table::setDT(covidregionaldata::get_regional_data(country = covid_regional_data_identifier))
  if (typeof(case_modifier_function) == "closure") {
    futile.logger::flog.trace("Modifying regional data")
    cases <- case_modifier_function(cases)
  }
  if (is.null(cases_subregion_source)) {
    futile.logger::flog.trace("Cleaning regional data")
    cases <- clean_regional_data(cases)
  }else {
    futile.logger::flog.trace("Cleaning regional data with %s as region source", cases_subregion_source)
    cases <- clean_regional_data(cases[, region := eval(parse(text = cases_region_source))])
  }
  # Check to see if the data has been updated  ------------------------------

  if (check_for_update(cases, last_run = here::here("last-update", paste0(region_name, ".rds")))) {

    # Set up cores -----------------------------------------------------

    no_cores <- setup_future(length(unique(cases$region)))

    # Run Rt estimation -------------------------------------------------------
    if (is.null(region_scale)) {
      regional_epinow_with_settings(reported_cases = cases,
                                    generation_time = generation_time,
                                    delays = list(incubation_period, reporting_delay),
                                    no_cores = no_cores,
                                    target_dir = paste0("subnational/", region_name, "/cases/national"),
                                    summary_dir = paste0("subnational/", region_name, "/cases/summary"))
    }else {
      regional_epinow_with_settings(reported_cases = cases,
                                    generation_time = generation_time,
                                    delays = list(incubation_period, reporting_delay),
                                    no_cores = no_cores,
                                    target_dir = paste0("subnational/", region_name, "/cases/national"),
                                    summary_dir = paste0("subnational/", region_name, "/cases/summary"),
                                    region_scale = region_scale)
    }
  }
}