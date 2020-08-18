source(here::here("R", "update-regional.R"))

update_regional(region_name = "afghanistan",
                case_modifier_function = function(cases){
                  cases <- cases[!is.na(iso_3166_2)]
                  return(cases)
                }
)
