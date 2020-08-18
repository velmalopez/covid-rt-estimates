source(here::here("R", "update-regional.R"))

update_regional(region_name = "afghanistan",
                covid_regional_data_identifier = "afghanistan",
                cases_subregion_source =  "province",
                case_modifier_function = function(cases){
                  cases <- cases[!is.na(iso_3166_2)]
                  return(cases)
                }
)
