library(ggplot2)
library(maps)
library(dplyr)



# Import data with geographic variables from Github
raceiatdat <- read.csv(file = "https://github.com/lizredford/map-iat/blob/master/raceiatdat.csv?raw=true") # transform GitHub url from 'View Raw' hyperlink into data frame

# raceiatdat starts w 100,000 rows; Take random sample of fewer rows so it runs faster while I'm testing ggplot
raceiatdat <- raceiatdat[sample(1:nrow(raceiatdat), 5000, replace = FALSE),]  

# make dataset smaller so it runs faster
raceiatdat <- select(raceiatdat, -MSAName, -MSANo, -datecode, -numiats, -religion, -countrycitnum)

raceiatdat$state <- raceiatdat$STATE # Change "state" variable to all lowercase 

# Some states don't have state numbers, which mapping won't like. Omit rows with missing data here
raceiatdat <- na.omit(raceiatdat)

raceiatdat$state <- as.character(raceiatdat$state) # was integer; change to character

# this .csv contains all state abbrevs, state nos., and lowercase state names
state_info <- read.csv(file = "https://github.com/lizredford/map-iat/blob/master/state_info.csv?raw=true") # transform GitHub url from 'View Raw' hyperlink into data frame

# this "states" dataframe has the lat & long info needed for mapping.
states <- map_data("state")

View(states)
states$state.name <- states$region

raceiatdat_states$state.name <- as.character(raceiatdat_states$state.name) # was integer; convert to chracter

raceiatdat_states <- inner_join(state_info, raceiatdat, by = "state") # join race IAT data to df that has lowercase state names

# Here is where it stops working; joining with "states" creates a dataset with 1.5 million rows. WHY??? -----
race_grouped_bystate <- raceiatdat_states %>% 
  group_by(state.name) %>% 
  summarize(value = mean(Implicit, na.rm = TRUE)) %>% 
  select(region = state.name, 
         value)

View(race_grouped_bystate)

raceiatdat_states2 <- inner_join(race_grouped_bystate, states, by = "region") # join IAT + lowercase names to df that has lat & long

View(raceiatdat_states2)

# These maps look WRONG -- values from gropuing by state do not match coloring in the map.
ggplot() + geom_polygon(data = raceiatdat_states2, 
                        aes(x = long, y = lat, group = group, fill = value), 
                        color = "white") + 
  coord_map("albers",  at0 = 45.5, lat1 = 29.5)

