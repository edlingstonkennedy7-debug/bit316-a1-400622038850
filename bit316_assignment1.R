# =============================================================================
# BIT316 R Programming - Assignment 1: Data Structures & Data Wrangling
# Programme : BSc. Information Technology, Level 300, BlueCrest College, Ghana
# Student   : Kennedy Edlingston   |   Student ID: 400622038850
# Dataset   : Star Wars characters (dplyr::starwars), exported to data/starwars.csv
# Run       : Open the project folder in RStudio (or setwd() to it), then
#             source("bit316_assignment1.R"). It runs top-to-bottom with no errors.
# =============================================================================

# ---- 0. Packages (all library() calls live here, at the top) ----------------
library(dplyr)   # data-wrangling verbs: filter, select, mutate, arrange, group_by...
library(tidyr)   # tidying tools: drop_na, replace_na, pivot_longer, pivot_wider
library(readr)   # fast, consistent CSV import with read_csv()

# Make the script reproducible: fix the random seed (used only for the demo vector)
set.seed(316)


# =============================================================================
# PART A - NATIVE DATA STRUCTURES
# =============================================================================

cat("\n================ PART A: NATIVE DATA STRUCTURES ================\n")

# ---- A1. Vectors: numeric and character -------------------------------------
# WHAT: build one numeric and one character vector with c().
# WHY : atomic vectors are R's basic building block; every column of a data
#       frame is a vector.
heights_cm <- c(172, 167, 96, 202, 150)                       # numeric vector
names_chr  <- c("Luke", "C-3PO", "R2-D2", "Vader", "Leia")    # character vector

# Vectorised operations: applied to every element at once, no loop needed.
heights_m  <- heights_cm / 100                  # convert cm to metres
heights_z  <- (heights_cm - mean(heights_cm)) / sd(heights_cm)  # z-scores
cat("Heights in metres:", heights_m, "\n")
cat("Mean height (cm):", mean(heights_cm), "| SD:", round(sd(heights_cm), 2), "\n")
cat("Upper-case names:", toupper(names_chr), "\n")        # vectorised on text too

# Indexing / subsetting: by position, by negative position, by logical test, by name
heights_cm[2]                 # 2nd element
heights_cm[c(1, 4)]           # 1st and 4th elements
heights_cm[-1]                # everything except the 1st
heights_cm[heights_cm > 160]  # logical subsetting: only values above 160
names(heights_cm) <- names_chr        # give each value a name
heights_cm["Vader"]                   # subset by name
print(heights_cm)

# ---- A2. Factor --------------------------------------------------------------
# WHAT: convert a character vector of categories into a factor.
# WHY : a factor stores a fixed set of categories (levels), which is how R
#       represents categorical variables for grouping and modelling.
side_chr <- c("Light", "Dark", "Light", "Dark", "Light", "Light")
side_fct <- factor(side_chr, levels = c("Light", "Dark"))
cat("\nFactor:\n"); print(side_fct)
cat("Levels:", levels(side_fct), "\n")
cat("Number of levels:", nlevels(side_fct), "\n")
print(table(side_fct))                # frequency of each level

# ---- A3. List with items of different types ---------------------------------
# WHAT: a list can hold a character, number, logical, vector and even a data frame.
# WHY : lists are R's general-purpose container for mixed content.
character_profile <- list(
  name      = "Luke Skywalker",              # character
  height_cm = 172,                           # numeric
  is_jedi   = TRUE,                          # logical
  films     = c("A New Hope", "Empire", "Jedi"),  # character vector
  scores    = c(math = 80, force = 95)       # named numeric vector
)

character_profile$name              # access by name with $
character_profile[["height_cm"]]    # access by name with [[ ]]
character_profile[[4]]              # access the 4th element by position
character_profile[["films"]][2]     # element inside an element
str(character_profile)              # structure of the whole list

# ---- A4. Matrix and data frame built by hand --------------------------------
# WHAT: a 3 x 3 numeric matrix (all one type) and a small data frame (mixed types).
my_matrix <- matrix(1:9, nrow = 3, ncol = 3, byrow = TRUE,
                    dimnames = list(c("r1", "r2", "r3"), c("c1", "c2", "c3")))
cat("\nMatrix:\n"); print(my_matrix)
my_matrix[2, ]        # a whole row (row 2)
my_matrix[, 3]        # a whole column (column 3)
my_matrix[2, 3]       # a single cell (row 2, column 3)
cat("Matrix dimensions:", dim(my_matrix), "\n")

small_df <- data.frame(
  name   = c("Luke", "Leia", "Han", "Yoda"),
  height = c(172, 150, 180, 66),
  jedi   = c(TRUE, FALSE, FALSE, TRUE),
  stringsAsFactors = FALSE
)
cat("\nData frame:\n"); print(small_df)
small_df[2, ]                 # a row   (Leia's record)
small_df[, "height"]          # a column as a vector (by name)
small_df$name                 # a column with $
small_df[3, "height"]         # a single cell (row 3, column "height")
small_df[small_df$jedi, ]     # rows where jedi is TRUE


# =============================================================================
# PART B - IMPORTING & EXPLORING
# =============================================================================

cat("\n================ PART B: IMPORT & EXPLORE ================\n")

# ---- B1. Import --------------------------------------------------------------
# WHAT: read the CSV with a relative path so it runs on any machine.
# WHY : read_csv() guesses column types, keeps strings as text and returns a tibble.
sw <- read_csv("data/starwars.csv", show_col_types = FALSE)

# Confirm it loaded: dimensions and column types
cat("Rows:", nrow(sw), "| Columns:", ncol(sw), "\n")
print(dim(sw))
print(sapply(sw, class))              # class of every column

# ---- B2. Overview ------------------------------------------------------------
glimpse(sw)        # compact column-by-column view (type + first values)
str(sw)            # base-R structure, for comparison
summary(sw)        # min/quartiles/mean for numbers; length/class for text
print(head(sw))    # first six rows

# ---- B3. Missing values per column ------------------------------------------
# WHAT: is.na() gives TRUE/FALSE for each cell; colSums() adds TRUE as 1.
# WHY : we must know where data are missing before choosing how to handle them.
na_counts <- colSums(is.na(sw))
print(na_counts)
# The same result as a tidy table, sorted from most to fewest missing values
na_table <- tibble::tibble(column = names(na_counts), n_missing = as.integer(na_counts)) %>%
  mutate(pct_missing = round(100 * n_missing / nrow(sw), 1)) %>%
  arrange(desc(n_missing))
print(na_table)
# Observation: birth_year (44) and mass (28) have the most missing values.


# =============================================================================
# PART C - WRANGLING WITH dplyr & tidyr
# =============================================================================

cat("\n================ PART C: WRANGLING ================\n")

# ---- C1. Pipe chain: filter -> select -> mutate -> arrange ------------------
# QUESTION: Which tall characters have the highest body-mass index (BMI)?
# WHAT: each verb passes its result to the next via the pipe %>%.
# WHY : a pipe reads left-to-right like a recipe and avoids temporary objects.
bmi_tbl <- sw %>%
  filter(!is.na(height), !is.na(mass), height > 100) %>%     # keep rows with data and height > 100 cm
  select(name, species, height, mass) %>%                    # keep only relevant columns
  mutate(bmi = round(mass / (height / 100)^2, 1)) %>%        # derived column: kg per m^2
  arrange(desc(bmi))                                         # largest BMI first
print(head(bmi_tbl, 10))
# Note: Jabba the Hutt has an extreme mass (1358 kg), so he tops the list.

# ---- C2. Handling missing values --------------------------------------------
# CHOICE (explained):
#  * height and mass are numeric measures needed for the calculations below.
#    Imputing a mean for a character's mass would invent data (a droid and a
#    Wookiee have very different masses), so I DROP rows only where the variable
#    needed for a given calculation is missing (drop_na on chosen columns).
#  * species is a categorical label. Dropping would waste rows that still have
#    valid height/mass, so I REPLACE its NA with the explicit label "Unknown".
#    This keeps the rows and makes the missingness visible instead of hidden.
sw_clean <- sw %>%
  mutate(species = replace_na(species, "Unknown")) %>%      # categorical NA -> "Unknown"
  drop_na(height, mass)                                      # numeric NA -> drop only on these columns
cat("Rows before:", nrow(sw), "| after dropping NA height/mass:", nrow(sw_clean), "\n")
cat("Remaining NA in species:", sum(is.na(sw_clean$species)), "\n")

# ---- C3. group_by() + summarise(): at least two statistics per group --------
# WHAT: split by species, then compute count, mean height, mean mass, max mass.
# WHY : grouped summaries answer "how does the measure differ between groups?"
species_summary <- sw_clean %>%
  group_by(species) %>%
  summarise(
    n           = n(),                              # count per group
    mean_height = round(mean(height), 1),           # average height
    mean_mass   = round(mean(mass), 1),             # average mass
    max_mass    = max(mass),                        # heaviest in the group
    .groups     = "drop"                            # return an ungrouped tibble
  ) %>%
  arrange(desc(n), species)
print(species_summary)

# A second grouping: by sex (a cleaner categorical column), with NA made explicit
sex_summary <- sw_clean %>%
  mutate(sex = replace_na(sex, "unknown")) %>%
  group_by(sex) %>%
  summarise(n = n(), mean_height = round(mean(height), 1), .groups = "drop")
print(sex_summary)

# ---- C4. Reshape with pivot_longer() / pivot_wider() ------------------------
# WHAT: species_summary has separate columns mean_height and mean_mass.
#       pivot_longer() stacks them into one 'measure' column and one 'value' column.
# WHY : the long format is tidier because each row is ONE observation
#       (species + measure + value) and each column is ONE variable. It is also
#       the shape that ggplot2 and group-wise tools expect.
top_species <- species_summary %>% filter(n >= 2)       # species with at least 2 members

species_long <- top_species %>%
  select(species, mean_height, mean_mass) %>%
  pivot_longer(cols = c(mean_height, mean_mass),
               names_to = "measure", values_to = "value")
print(species_long)

# pivot_wider() reverses the reshape, proving no information was lost
species_wide <- species_long %>%
  pivot_wider(names_from = measure, values_from = value)
print(species_wide)
cat("Round trip identical:", isTRUE(all.equal(top_species %>% select(species, mean_height, mean_mass),
                                               species_wide)), "\n")

# ---- C5. Save an output for the repository ----------------------------------
dir.create("output", showWarnings = FALSE)
write_csv(species_summary, "output/species_summary.csv")
cat("\nSaved output/species_summary.csv\n")


# =============================================================================
# PART D - REPRODUCIBILITY
# =============================================================================
cat("\n================ PART D: SESSION INFO ================\n")
cat("Script completed successfully.\n")
sessionInfo()
