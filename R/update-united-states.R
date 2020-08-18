source(here::here("R", "update-regional.R"))

update_regional(region_name = "united-states",
                covid_regional_data_identifier = "USA",
                cases_subregion_source =  "state",
                region_scale = "State"
)
