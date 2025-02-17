#' Sync Estimates From Azure Storage
#' 
#' @description This utility allows for programmatic downloading of results
#' from our reproduction number pipeline which are stored in Azure blob storage. 
#' It requires an installation of `azcopy` to function for which we provide an 
#' install script for use with Linux. By default it will download all summary
#' estimates. Optionally, it can also return plots and samples (with short term
#' archiving of previous estimates). Using the file structure of `covid-rt-estimates` 
#' it can also be used to target specific estimates by setting the `target_dir`
#' argument.
#' 
#' `azcopy`: https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10
#' 
#' Install file: https://github.com/epiforecasts/covid-rt-estimates/blob/master/bin/install_azcopy.sh
#' 
#' 
#' @param local_dir A character string containing the local folder to download estimates into.
#' @param include A character vector indicating the results type to download Options are
#' "csv", "rds", "png", and "log". The default is "csv" which represents a summary.
#' @param target_dir A character string indicating the internal folder to target in the 
#' Azure blob storage. Defaults to "results". This may be used to selectively download results.
#' @param blob A character string indicating the Azure blob address.
#' @return NULL
#' @export
#' @importFrom AzureStor call_azcopy
#' @examples
#' get_estimates("covid-rt-estimates")
get_estimates <- function(local_dir, include = "csv", target_dir = "results", 
                          blob = "https://epinowcovidrstorage.blob.core.windows.net") {
  
  # Check Args
  include <- match.arg(include, choices = c("csv", "rds", "png", "log"), several.ok = TRUE)
  
  # Add in target directory
  blob <- file.path(blob, target_dir, "*")
  
  # Check and create local addresses
  if (!dir.exists(local_dir)) {
    dir.create(local_dir, recursive = TRUE)
  }
  
  # define inclusion list
  ic <- ""
  add_inc <- function(ic, inc, dirs = c("latest", "summary")) {
    if (inc %in% include) {
      ic <- paste(c(paste(dirs, paste0(".+\\.", inc), sep ="/"), ic),
		  collapse = ";")
    } 
    return(ic)
  }
  ic <- add_inc(ic, "csv")
  ic <- add_inc(ic, "rds")
  ic <- add_inc(ic, "png")

  # remove trailing semicolon
  ic <- sub(";$", "", ic)
  
  # get estimates
  AzureStor::call_azcopy("copy", blob, local_dir, "--recursive",
			 "--include-regex", ic)
  return(invisible(NULL))
}
