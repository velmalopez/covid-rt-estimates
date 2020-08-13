source(here::here("R", "update-regional.R"))

update.regional("afghanistan",
                "afghanistan",
                function(cases){
                  cases <- cases[!is.na(iso_3166_2)]
                  return(cases)
                }
)
