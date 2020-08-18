source(here::here("R", "update-regional.R"))

update_regional(region_name = "united-states",
                covid_regional_data_identifier = "USA",
                region_scale = "State"
)
