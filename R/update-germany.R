source(here::here("R", "update-regional.R"))

update.regional(region_name = "germany",
                region_identifier = "Germany",
                cases_region_source =  "bundesland"
)
