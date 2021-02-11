
get_estimates <- function(local_dir, include = "csv", target_dir = "results", 
                          blob = "https://epinowcovidrstorage.blob.core.windows.net") {

    # Check Args
    include <- match.arg(include, choices = c("csv", "rds", "png", "log"), several.ok = TRUE)
 
    # Add in target directory
    blob <- file.path(blob, target_dir)
  
    # Check and create local addresses
    if (!dir.exists(local_dir)) {
        dir.create(local_dir, recursive = TRUE)
    }

    # define inclusion list
    ic <- "exactName"
    add_inc <- function(ic, inc) {
        if (inc %in% include) {
        ic <- paste0("*.", inc, ";", ic)
        } 
        return(ic)
    }
    ic <- add_inc(ic, "csv")
    ic <- add_inc(ic, "rds")
    ic <- add_inc(ic, "png")

    # get estimates
    AzureStor::call_azcopy("sync", blob, local_dir, "--include-pattern", ic) 
    return(invisible(NULL))
}
