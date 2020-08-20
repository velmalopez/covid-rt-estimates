# Packages -----------------------------------------------------------------
require(EpiNow2, quietly = TRUE)
require(covidregionaldata, quietly = TRUE)
require(data.table, quietly = TRUE)
require(future, quietly = TRUE)
require(lubridate, quietly = TRUE)

# Load utils --------------------------------------------------------------

source(here::here("R", "utils.R"))


#' Update Regional
#'
#' @description Processes regional data in an abstract fashion to reduce code duplication
#' @param region_name String, name of region, used for filepaths and filenames
#' @param covid_regional_data_identifier String, region identifier used by covidregionaldata to get the data. If not supplied
#' then defaults to `region_name`.
#' @param case_modifier_function Function, passed the cases, should return the cases. Method of modifying the returned data for a specific region if needed
#' @param generation_time optional overrides for the loaded rds file. If present won't be reloaded from disk.
#' @param incubation_period optional overrides for the loaded rds file. If present won't be reloaded from disk.
#' @param reporting_delay optional overrides for the loaded rds file. If present won't be reloaded from disk.
#' @param cases_subregion_source string, optional specification of where to get the list of regions from the cases dataset
#' @param region_scale string, specify the region scale to epinow
update_regional <- function(region_name, covid_regional_data_identifier, case_modifier_function, 
                            generation_time, incubation_period, reporting_delay, 
                            cases_subregion_source = "region_level_1", 
                            region_scale = "Region") {
   
  # setting debug level to trace whilst still in beta. #ToDo: change this line once production ready
  setup_log(threshold = futile.logger::TRACE)
  
  futile.logger::flog.info("Processing regional dataset for %s", region_name)

  # Update delays -----------------------------------------------------------
  if (missing(generation_time)) {
    generation_time <- readRDS(here::here("data", "generation_time.rds"))
  }
  if (missing(incubation_period)) {
    incubation_period <- readRDS(here::here("data", "incubation_period.rds"))
  }
  if (missing(reporting_delay)) {
    reporting_delay <- readRDS(here::here("data", "onset_to_admission_delay.rds"))
  }
 
  # Get cases  ---------------------------------------------------------------
  futile.logger::flog.info("Getting regional data")
  
  if (missing(covid_regional_data_identifier)) {
    covid_regional_data_identifier <- region_name
  }
  
  cases <- data.table::setDT(covidregionaldata::get_regional_data(country = covid_regional_data_identifier, 
                                                                  localise_regions = FALSE))
  if (!missing(case_modifier_function) && typeof(case_modifier_function) == "closure") {
    futile.logger::flog.trace("Modifying regional data")
    cases <- case_modifier_function(cases)
  }

  if (!cases_subregion_source %in% colnames(cases)) {
    futile.logger::flog.error("invalid source column name %s - only the following are valid",cases_subregion_source)
    futile.logger::flog.error(colnames(cases))
    stop("Invalid column name")
  }
  
  futile.logger::flog.trace("Remapping case data with %s as region source", cases_subregion_source)
  data.table::setnames(cases, cases_subregion_source, "region")

  futile.logger::flog.trace("Cleaning regional data")
  cases <- clean_regional_data(cases)
  
  # Check to see if the data has been updated  ------------------------------
  if (check_for_update(cases, last_run = here::here("last-update", paste0(region_name, ".rds")))) {
    
    # Set up cores -----------------------------------------------------
    no_cores <- setup_future(length(unique(cases$region)))

    # Run Rt estimation -------------------------------------------------------
    regional_epinow_with_settings(reported_cases = cases,
                                  generation_time = generation_time,
                                  delays = list(incubation_period, reporting_delay),
                                  no_cores = no_cores,
                                  target_dir = paste0("subnational/", region_name, "/cases/national"),
                                  summary_dir = paste0("subnational/", region_name, "/cases/summary"),
                                  region_scale = region_scale)
  }
}
