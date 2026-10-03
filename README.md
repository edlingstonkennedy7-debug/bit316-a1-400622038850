# BIT316 Assignment 1 - Data Structures & Data Wrangling

**Course:** BIT316 R Programming, BlueCrest College, Ghana
   **Student:** Kennedy Edlingston (400622038850)
   **Lecturer:** Mark Kofi Amoani Mensah

## What this project does
`bit316_assignment1.R` is a single R script, organised in four parts:

| Part | Content |
|------|---------|
| A | Native structures: numeric and character vectors, vectorised operations, indexing, factor and its levels, mixed-type list, matrix, hand-built data frame |
| B | Import with `readr::read_csv()`, dimensions and column types, `glimpse()`, `str()`, `summary()`, `head()`, and missing values per column |
| C | A `dplyr` pipe chain (filter, select, mutate, arrange), `group_by()` + `summarise()`, missing-value handling, and `pivot_longer()` / `pivot_wider()` |
| D | Reproducibility: libraries at the top, commented code, this README, git history |

## Dataset
The built-in `starwars` dataset from the **dplyr** package (87 characters, 14 variables), a dataset named as acceptable in the assignment brief.
`data-raw/make_dataset.R` exports it to `data/starwars.csv`. The list-columns `films`, `vehicles` and `starships` are dropped because a CSV cannot store them; `n_films` (number of films) replaces them. The main script loads the CSV from the repository, so it runs on any machine.

## Packages required
`dplyr`, `tidyr`, `readr` (all part of the tidyverse). R 4.x is required.

```r
install.packages(c("dplyr", "tidyr", "readr"))
```

## How to run
1. Clone or unzip the repository and open the folder in RStudio (or `setwd()` to it).
2. In a fresh R session run:
   ```r
   source("bit316_assignment1.R")
   ```
   or from a terminal: `Rscript bit316_assignment1.R`
3. Output is printed to the console. `output/species_summary.csv` is written, and `output/console_log.txt` is a saved log of a complete run.

(To regenerate the CSV: `source("data-raw/make_dataset.R")`.)

## Summary of findings
- The data has **87 rows and 12 columns** after export. The most incomplete columns are **birth_year (44 missing, 50.6%)** and **mass (28 missing, 32.2%)**.
- Dropping rows with missing height or mass leaves **59 characters**. Missing `species` was replaced with "Unknown" so those rows were kept.
- **Humans** are the largest group (20 with complete data), averaging about 180 cm and 81 kg. **Wookiees** are the tallest (231 cm) and Droids the shortest of the multi-member groups (140 cm).
- **Jabba the Hutt** (1358 kg) is a strong outlier and has by far the highest BMI (443), which would distort any mean mass if not noticed.
- `pivot_longer()` turned the separate `mean_height` and `mean_mass` columns into `measure` / `value` columns, which is tidier (one observation per row) and `pivot_wider()` restored the original exactly.

## Repository structure
```
bit316-a1-<studentID>/
|-- bit316_assignment1.R   main script
|-- data/starwars.csv      dataset used
|-- data-raw/make_dataset.R  how the CSV was produced
|-- output/                console_log.txt, species_summary.csv
|-- README.md
```
