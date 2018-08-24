library(ggplot2)
library(maps)
library(dplyr)

# {import data} -----------------------------------------------------------

# Import data with geographic variables from Github
raceiatdat <- read.csv(file = "https://github.com/lizredford/map-iat/blob/master/raceiatdat.csv?raw=true") # transform GitHub url from 'View Raw' hyperlink into data frame

# this .csv contains all state abbrevs, state nos., and lowercase state names
state_info <- read.csv(file = "https://github.com/lizredford/map-iat/blob/master/state_info.csv?raw=true") # transform GitHub url from 'View Raw' hyperlink into data frame

# prep for choroplethr ----------------------------------------------------

raceiatdat$state <- raceiatdat$STATE # Change "state" variable to all lowercase to match "state info" table, so that it can be merged with that table

raceiatdat$state <- as.character(raceiatdat$state)

# Remove people who don't report their state 
raceiatdat <- raceiatdat[raceiatdat$state != "",]

# make dataset smaller so it runs faster
raceiatdat <- select(raceiatdat, -MSAName, -MSANo, -datecode, -numiats, -religion, -countrycitnum)

# merge state info with iat data
raceiatdat <- merge(raceiatdat, state_info, 
              by = "state", 
              all = TRUE)

race_grouped_bystate <- raceiatdat %>% 
  group_by(state.name) %>% 
  summarize(value = mean(Implicit, na.rm = TRUE)) %>% 
  select(region = state.name, 
         value)

### ggplot: Get lat & long info -----

# this "states" dataframe has the lat & long info needed for mapping.
states <- map_data("state")

states$state.name <- states$region

# join IAT + lowercase names to df that has lat & long
race_grouped_bystate <- inner_join(race_grouped_bystate, 
                                states, 
                                by = "region") 

ggplot() + geom_polygon(data = race_grouped_bystate, 
                        aes(x = long, y = lat, group = group, fill = value), 
                        color = "white") + 
  coord_map("albers",  at0 = 45.5, lat1 = 29.5)

# Example of what data and map should look like for ggplot -----
# from https://ggplot2.tidyverse.org/reference/map_data.html

if (require("maps")) {
states <- map_data("state")
arrests <- USArrests

choro <- merge(states, arrests, sort = FALSE, by = "region")
choro <- choro[order(choro$order), ]

ggplot(choro, aes(long, lat)) +
  geom_polygon(aes(group = group, fill = assault / murder)) +
  coord_map("albers",  at0 = 45.5, lat1 = 29.5)
}

View(choro)

states %>%
  filter(region == "alabama") %>%
  ggplot() + geom_polygon(aes(x=long, y=lat, group = group))

