source(here::here("R", "update-regional.R"))

update_regional(region_name = "brazil",
                covid_regional_data_identifier = "Brazil",
                cases_subregion_source =  "state"
)
