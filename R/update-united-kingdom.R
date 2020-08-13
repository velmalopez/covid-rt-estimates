source(here::here("R", "update-regional.R"))

update.regional("united-kingdom",
                "UK",
                function(cases) {
                  return(cases)
                }
)