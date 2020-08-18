source(here::here("R", "update-regional.R"))

update_regional(region_name = "germany",
                covid_regional_data_identifier = "Germany",
                cases_subregion_source =  "bundesland"
)
