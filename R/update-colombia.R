source(here::here("R", "update-regional.R"))

update_regional(region_name = "colombia",
                covid_regional_data_identifier = "Colombia",
                cases_region_source =  "departamento"
)
