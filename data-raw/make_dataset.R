# data-raw/make_dataset.R
# PURPOSE: Export the built-in dplyr::starwars dataset to a plain CSV file so that
#          the main analysis script can load it from the repository (Section 2 of
#          the brief requires loading from a file, not from a package object).
# NOTE:    films, vehicles and starships are list-columns that cannot be stored in
#          a CSV, so they are replaced with a simple count of how many films each
#          character appears in.

library(dplyr)
library(readr)

starwars |>
  mutate(n_films = lengths(films)) |>   # lengths() counts items in each list cell
  select(-films, -vehicles, -starships) |>
  write_csv("data/starwars.csv", na = "NA")

message("Wrote data/starwars.csv")
