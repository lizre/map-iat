# mapping iat to state/county

# {setup} -----------------------------------------------------------------

#install.packages("dplyr")
require(dplyr)
#install.packages("stringr")
require(stringr)
#install.packages("choroplethr")
require(choroplethr)
#install.packages("choroplethrMaps")
require(choroplethrMaps)

library(here)

# {import data} -----------------------------------------------------------

# Import data with geographic variables from Github
raceiatdat <- read.csv(file = "https://github.com/lizredford/map-iat/blob/master/raceiatdat.csv?raw=true") # transform GitHub url from 'View Raw' hyperlink into data frame

# this .csv contains all state abbrevs, state nos., and lowercase state names
state_info <- read.csv(file = "https://github.com/lizredford/map-iat/blob/master/state_info.csv?raw=true") # transform GitHub url from 'View Raw' hyperlink into data frame

# prep for choroplethr ----------------------------------------------------

raceiatdat$state <- raceiatdat$STATE # Change "state" variable to all lowercase to match "state info" table, so that it can be merged with that table

# merge state info with iat data
raceiatdat <- merge(raceiatdat, state_info, 
              by = "state", 
              all = TRUE)

# choropleth needs lower-case state name to map by state 
# (already in data from state_info)

# Some states don't have state numbers, which chloropleth won't like. Omit rows with missing data here.
raceiatdat <- na.omit(raceiatdat)
# leaves 32,774 cases

# choroplethr also needs combined state/county fips to map by county
# however, county number needs to be 3 digits, so leading zeroes must be added 
raceiatdat$CountyNo <- str_pad(raceiatdat$CountyNo, 3, pad = "0")

# now concatenation can happen
raceiatdat <- raceiatdat %>% 
  mutate(county.full = paste(state.no, CountyNo, sep = ""))

# county map --------------------------------------------------------------

# county_choropleth() needs a dataframe with only two columns, $region and $value
# in this case, $region is county

# to check what county_choropleth() is looking for, check out $region in
data(county.regions)
glimpse(county.regions)

# prepare data for county_choropleth()
df.county <- raceiatdat %>% 
  group_by(county.full) %>% 
  summarize(value = mean(Implicit, na.rm = TRUE)) %>% 
  select(region = county.full, 
         value) %>% 
  mutate(region = as.numeric(region))

# create map
county_choropleth(df.county, 
                  title = "Average Race IAT Score by County", 
                  legend = "Race IAT Score")


# state map ---------------------------------------------------------------

# state_choropleth() needs a dataframe with only two columns, $region and $value
# in this case, $region is state (lower-case)

# to check what county_choropleth() is looking for, check out $region in
data(state.regions)
glimpse(state.regions)

# prepare data for state_choropleth()
df.state <- raceiatdat %>% 
  group_by(state.name) %>% 
  summarize(value = mean(Implicit, na.rm = TRUE)) %>% 
  select(region = state.name, 
         value)

# create map
state_choropleth(df.state, 
                 title = "Average Race IAT Score by State", 
                 legend = "Race IAT Score")


# {references} ------------------------------------------------------------

# choroplethr
# source: https://stackoverflow.com/questions/22679951/us-choropleth-map-in-r
# source: https://cran.r-project.org/web/packages/choroplethr/choroplethr.pdf

# changing color scheme in choroplethr
# source: https://www.r-bloggers.com/advanced-choroplethr-changing-color-scheme/

