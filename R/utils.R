#' Set up parallel processing on all available cores
setup_future <- function(jobs) {
  if (!interactive()) {
    ## If running as a script enable this
    options(future.fork.enable = TRUE)
  }
  
  
  plan(tweak(multiprocess, workers = min(future::availableCores(), jobs)),
       gc = TRUE, earlySignal = TRUE)
  
  
  jobs <- max(1, ceiling(future::availableCores() / jobs))
  return(jobs)
}


#' Check data to see if updated since last run
check_for_update <- function(cases, last_run) {
  if (file.exists(last_run)){
    last_run <- readRDS(last_run)
    
    current_max_date <- max(cases$date, na.rm = TRUE)
    
    if (current_max_date >= last_run) {
      stop("Data has not been updated since last run. 
      If wanting to run again then remove ", last_run)
    }
  }
  
  return(invisible(NULL))
}
#' Clean regional data
clean_regional_data <- function(cases) {
  cases <- cases[, .(region, date = as.Date(date), confirm = cases_new)]
  cases <- cases[, .SD[date >= (max(date) - lubridate::weeks(8))], by = region]
  cases <- cases[!is.na(confirm)]
  data.table::setorder(cases, date)
}

#' Regional EpiNow with settings
regional_epinow_with_settings <- function(reported_cases, generation_time, delays, 
                                          target_dir, summary_dir, no_cores) {
  
  regional_epinow(reported_cases = reported_cases,
                  generation_time = generation_time,
                  delays = delays,
                  horizon = 14, burn_in = 7,
                  samples = 2000, warmup = 500,
                  cores = no_cores, chains = 2,
                  target_folder = target_dir,
                  summary_dir = summary_dir,
                  return_estimates = FALSE, verbose = FALSE)
  
  return(invisible(NULL))
}