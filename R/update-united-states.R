source(here::here("R", "update-regional.R"))

update.regional(region_name = "united-states",
                covid_regional_data_identifier = "USA",
                cases_region_source =  "state",
                region_scale = "State"
)
