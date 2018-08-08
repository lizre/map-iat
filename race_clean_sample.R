# This code was used to take certain variables from, and a random sample of, data from the Gender-Science Implicit Association Test. This data had already been cleaned as part of the same Documenting Bias project.

library(here)
library(dplyr)
library(haven)

raceiatdat <- read_sav("raceiat_cleaned.sav") %>% select(Implicit, Explicit, raceomb, sexnum, politics, age, year, datecode, numiats, religion, datecode, countrycitnum, MSANo, CountyNo, MSAName, STATE) # import data, selecting only needed variables
View(raceiatdat)
#  N = 2 219 014

raceiatdat <- raceiatdat[sample(1:nrow(raceiatdat), 50000, replace = FALSE),] # Take random sample of 50000 rows; about 2.2%

### Write data to csv to export ##### ================
library(readr)
write_csv(raceiatdat, "raceiatdat.csv") # Export data to use for mapping
