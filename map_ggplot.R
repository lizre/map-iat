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

### Get lat & long info -----

# this "states" dataframe has the lat & long info needed for mapping.
states <- map_data("state")
states$state.name <- states$region

# join IAT + lowercase names to df that has lat & long
race_grouped_bystate <- inner_join(race_grouped_bystate, 
                                states, 
                                by = "region") 

## # ggplot without labels -----

ggplot() + geom_polygon(data = race_grouped_bystate, 
                        aes(x = long, y = lat, group = group, fill = value), 
                        color = "white") + 
  coord_map("albers",  at0 = 45.5, lat1 = 29.5) +
  theme(legend.position = "bottom") +
  guides(fill = guide_colorbar(barwidth = 20, barheight = 1.0)) 


## # ggplot with state labels -----

# Use state_info to add state abbreviations to be used for labelling
state_info$region <- state_info$state.name
race_grouped_bystate <- merge(race_grouped_bystate, state_info, by = "region")

# Create dataframe of labels
statelabels <- aggregate(cbind(long, lat) ~ state, data = race_grouped_bystate, FUN = function(x) mean(range(x)))

# Some state labels aren't in good positions; can change here 
# View(statelabels)
statelabels[12, c(2:3)] <- c(-114.5, 43.5)  # alter idaho's coordinates
statelabels[17, c(2:3)] <- c(-92.5, 31.75)  # alter louisiana's coordinates
statelabels[21, c(2:3)] <- c(-84.5, 42.75)  # alter michigan's coordinates
statelabels[9, c(2, 3)] <- c(-81.5, 28.75)  # alter florida's angle and coordinates
statelabels[44, c(2, 3)] <- c(-79, 37)      # alter virginia's angle and coordinates
statelabels[45, c(2, 3)] <- c(-72.87, 45.7) # vermont
statelabels[29, c(2, 3)] <- c(-71.64, 43.5) # nh
statelabels[18, c(2, 3)] <- c(-70, 42.5)    # ma
statelabels[32, c(2, 3)] <- c(-116.5, 40)   # nevada 
statelabels[25, c(2, 3)] <- c(-109, 47)     # montana
statelabels[35, c(2, 3)] <- c(-97.5, 35.5)  # oklahoma
statelabels[22, c(2, 3)] <- c(-94, 47)      # minnesota
statelabels[38, c(2, 3)] <- c(-71, 41.3)    # ri
statelabels[30, c(2, 3)] <- c(-73.22, 40.15)    # nj
statelabels[8, c(2, 3)] <- c(-74.42, 38.9)    # de
statelabels[19, c(2, 3)] <- c(-74.2, 38)    # md
statelabels[7, c(2, 3)] <- c(-74.2, 37)    # dc
statelabels[26, c(2, 3)] <- c(-79.9, 35.6)    # nc
statelabels[44, c(2, 3)] <- c(-79, 37.5)    # va
statelabels[16, c(2, 3)] <- c(-85.68584, 37.5)    # ky
statelabels[4, c(2, 3)] <- c(-120.25830, 37.27950)    # ca

ggplot() + geom_polygon(data = race_grouped_bystate, 
                        aes(x = long, y = lat, group = group, fill = value), 
                        color = "white") +
  theme(legend.position = "bottom") +
  guides(fill = guide_colorbar(barwidth = 20, barheight = 1.0)) +
  coord_map("albers",  at0 = 45.5, lat1 = 29.5) +
  geom_text(data = statelabels, aes(long, lat, label = state), size = 4.0) 

## # ggplot with value labels -----

# Add IAT values to labels coordinates.
race_grouped_bystate2 <- raceiatdat %>% 
  group_by(state.name) %>% 
  summarize(value = mean(Implicit, na.rm = TRUE)) %>% 
  select(region = state.name, 
         value)

valuelabels_bystate <- merge(state_info, race_grouped_bystate2, 
              by = "region", 
              all = TRUE)
valuelabels_bystate <- valuelabels_bystate %>% select(state, state.name, value)
valuelabels_bystate <- merge(valuelabels_bystate, statelabels, 
              by = "state",
              all = TRUE)

valuelabels_bystate$value <- round(valuelabels_bystate$value, 2) # round for labelling map
valuelabels_bystate <- na.omit(valuelabels_bystate)

# remove leading 0s from values to take up less space on map
library(weights)
valuelabels_bystate$value <- rd(valuelabels_bystate$value) 

# change variable name to one I'd prefer to print on ggplot image
valuelabels_bystate$`IAT score` <- valuelabels_bystate$value

ggplot() + geom_polygon(data = race_grouped_bystate, 
                        aes(x = long, y = lat, group = group, fill = value), 
                        color = "white") +
  labs(fill='IAT score') +
  theme_void() +
  theme(legend.position = "bottom") +
  guides(fill = guide_colorbar(barwidth = 20, barheight = 1.0)) +
  coord_map("albers",  at0 = 45.5, lat1 = 29.5) +
  geom_text(data = valuelabels_bystate, 
            aes(long, lat, label = value), 
            size = 4.0) 

ggsave("raceiat_bystate_valuelabels.png", width = 8, height = 5, units = c("in"), dpi = 300)

# Use this to keep latitude & longtitude lines but remove axis titles and text  
#        axis.text.x = element_blank(),
#        axis.text.y = element_blank(),
#        axis.ticks = element_blank(),
#        axis.title.y = element_blank(),
 #       axis.title.x = element_blank())


### References -----

# labelling chloropleths in ggplot from https://trinkerrstuff.wordpress.com/2013/07/05/ggplot2-chloropleth-of-supreme-court-decisions-an-tutorial/
