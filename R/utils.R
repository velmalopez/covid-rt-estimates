#' Set up logging to file
setup_log <- function(threshold = "INFO", file = "info.log") {
  futile.logger::flog.threshold(threshold)
  
  futile.logger::flog.appender(appender.tee(file))
  
  return(invisible(NULL))
}


#' Set up parallel processing on all available cores
setup_future <- function(jobs) {
  if (!interactive()) {
    ## If running as a script enable this
    options(future.fork.enable = TRUE)
  }
  
  workers <- min(future::availableCores(), jobs)
  cores_per_worker <- max(1, round(future::availableCores() / workers, 0))
  
  futile.logger::flog.info("Using %s workers with %s cores per worker", 
                           workers, cores_per_worker)
  future::plan("multiprocess", workers = workers,
               gc = TRUE, earlySignal = TRUE)
  
  
  return(cores_per_worker)
}


#' Check data to see if updated since last run
check_for_update <- function(cases, last_run, data) {
  
  current_max_date <- max(cases$date, na.rm = TRUE)
    
  if (file.exists(last_run)){
    last_run_date <- readRDS(last_run)
   
    if (current_max_date <= last_run_date) {
      futile.logger::flog.info("Skipping estimation for %s as the data is unchanged from the %s",
                               data, as.character(last_run_date))
      stop("Data has not been updated since last run. 
      If wanting to run again then remove ", last_run)
    }
    
    futile.logger::flog.info("Initialising estimates for: %s", region)
    
    return(invisible(NULL))
  }
    
  saveRDS(current_max_date, last_run)
  
  return(invisible(NULL))
}

#' Clean regional data
clean_regional_data <- function(cases) {
  cases <- cases[, .(region, date = as.Date(date), confirm = cases_new)]
  cases <- cases[date <= Sys.Date()]
  cases <- cases[, .SD[date <= (max(date, na.rm = TRUE) - lubridate::days(3))], by = region]
  cases <- cases[, .SD[date >= (max(date) - lubridate::weeks(12))], by = region]
  cases <- cases[!is.na(confirm)]
  data.table::setorder(cases, date)
}

#' Regional EpiNow with settings
regional_epinow_with_settings <- function(reported_cases, generation_time, delays, 
                                          target_dir, summary_dir, no_cores,
                                          region_scale = "Region") {
  
  regional_epinow(reported_cases = reported_cases,
                  generation_time = generation_time,
                  delays = delays, non_zero_points = 14,
                  horizon = 14, burn_in = 14,
                  samples = 2000, warmup = 500,
                  cores = no_cores, chains = ifelse(no_cores <= 2, 2, no_cores),
                  target_folder = target_dir,
                  summary_dir = summary_dir,
                  region_scale = region_scale,
                  return_estimates = FALSE, verbose = FALSE)
  
  future::plan("sequential")
  return(invisible(NULL))
}
