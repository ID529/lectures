library(raster)
library(sf)
library(mapview)
library(janitor)
library(tidyverse)
library(RColorBrewer)

# google: get shapefiles for states of india in r 
# results: 
#   - https://rstudio-pubs-static.s3.amazonaws.com/435552_5656a7fe6636474fb0f8d4222d79db2c.html 
#.   -> not useful, they don't give away the shapefiles;  plus i'm looking for something programmatic 
# 
#   - https://stackoverflow.com/questions/22997276/an-r-package-for-india 
#.    -> promising, but their code didn't run. follow up on the source they provided...
# 
#.  - https://stackoverflow.com/questions/5126745/gadm-maps-cross-country-comparison-graphics 
#.    -> trying to adapt this code: 
#.       success!  looks like I've downloaded some shapefiles 

india <- getData("GADM", country = 'IND', level = 1)

# let's look at the data
head(india) # okay, it looks like NAME_1 will probably be the state names I'm looking for

str(india, max.level=1) # good, it's spatial data, though we probably want to work with it in sf

# at this point I made the mistake of trying to plot it
# plot(india) 
# this kept hanging -- not sure if the data is too big to plot or if there's some bug

# converting to sf format since those are generally easier to work with
india_sf <- india |> sf::st_as_sf()

# let's try using mapview since i think the html & javascript based approach
# might be less likely to hang 
mapview(india_sf)

# google: why is geom_sf taking so long 
#    results: https://www.reddit.com/r/Rlanguage/comments/vxyou8/plotting_geospatial_data_is_so_slow_how_to_speed/ 
#     skimming answers: 
#     Try using st_simplify to remove some detail and plot again
#     That made a huge difference! It now plots almost instantly.
#      I added this line:
#        sg_hb <- st_simplify(sg_hb, dTolerance = 75)
#    
# i think the data was too big because using st_simplify on it made it
# significantly faster to run
# 
# checking ?st_simplify, the dTolerance argument is specified in meters when
# using the st_simplify function;  st_simplify simplifies geometries by removing
# verticies, so I am totally fine with removing vertices at the 75m resolution
# level when we're only interested in making maps of the entire country
india_sf <- india_sf |> sf::st_simplify(dTolerance=75)

# now this runs: 
ggplot(india_sf) + 
  geom_sf()

# here's the data i wanted to reproduce: 
# https://en.wikipedia.org/wiki/List_of_Indian_states_and_union_territories_by_literacy_rate


# i used datapasta::tribble_paste() to paste this data:
# and then I cleaned it by hand in several places
literacy_rates <- tibble::tribble(
                  ~State.or.UT, ~Average, ~Male, ~Female,
         "Andaman and Nicobar",  "86.27", 90.11,   81.84,
              "Andhra Pradesh",   "66.4", 75.56,   59.74,
           "Arunachal Pradesh",  "66.95", 73.69,   59.57,
                       "Assam",  "73.18", 78.81,   67.27,
                       "Bihar",  "69.82", 73.39,   53.33,
                "Chhattisgarh",  "71.04", 81.45,   60.59,
                  "Chandigarh",  "86.43", 90.54,   81.38,
      "Dadra and Nagar Haveli",  "77.65", 86.46,   65.93,
               "Daman and Diu",  "87.07", 91.48,   79.59,
                "NCT of Delhi",  "86.34", 91.03,   80.93,
                        "Goa",   "87.4", 92.81,   81.84,
                     "Gujarat",  "79.31", 87.23,   70.73,
                     "Haryana",  "76.64", 85.38,   66.77,
            "Himachal Pradesh",  "83.78", 90.83,    76.6,
           "Jammu and Kashmir",  "68.74", 78.26,   58.01,
                   "Jharkhand",  "66.41", 78.45,   56.21,
                   "Karnataka",   "75.6", 82.85,   68.13,
                      "Kerala",  "93.91", 96.02,   91.98,
                 "Lakshadweep",  "92.28", 96.11,   88.25,
              "Madhya Pradesh",  "70.63", 80.53,   60.02,
                 "Maharashtra",  "82.91", 89.82,   75.48,
                     "Manipur",  "79.85", 86.49,   73.17,
                   "Meghalaya",  "75.48", 77.17,   73.78,
                     "Mizoram",  "91.58", 93.72,    89.4,
                    "Nagaland",  "80.11", 83.29,   76.69,
                      "Odisha",  "73.45",  82.4,   64.36,
                  "Puducherry",  "86.55", 92.12,   81.22,
                      "Punjab",  "76.68", 81.48,   71.34,
                   "Rajasthan",  "67.06", 80.51,   52.66,
                      "Sikkim",   "82.2", 87.29,   76.43,
                  "Tamil Nadu",  "80.33", 86.81,   73.86,
                   "Telangana",      "–",    NA,      NA,
                     "Tripura",  "87.75", 92.18,   83.15,
                 "Uttarakhand",  "79.63", 88.33,    70.7,
               "Uttar Pradesh",  "69.72", 79.24,   59.26,
                 "West Bengal",  "77.08", 82.67,   71.16
  )

# i hate names with . in them, so i'm going to use janitor::clean_names to automatically
# improve the names in the data frame
literacy_rates <- literacy_rates |> janitor::clean_names()

# fix the rates to be actual numbers
literacy_rates$average <- literacy_rates$average |> readr::parse_number()

# use anti_join to check for mismatches
anti_join(india_sf, literacy_rates, by = c("NAME_1" = "state_or_ut"))
anti_join(literacy_rates, india_sf, by = c("state_or_ut" = "NAME_1"))

# create a merged dataset
merged_data <- india_sf |> left_join(literacy_rates, by = c("NAME_1" = "state_or_ut"))


# we can use mapview to create an interactive visualization
mapview(merged_data, zcol = 'average')

# google: set color palette mapview
#   click through a few links...
#   https://stackoverflow.com/questions/60099307/add-color-palette-to-mapview-map
# 
#    suggests: 
#   mapview(franconia, zcol = "SHAPE_LEN", col.regions=brewer.pal(9, "YlGn"))

# let's try something similar
mapview(merged_data, zcol = "average", col.regions = brewer.pal(7, "Blues"))

# okay, but i want less opacity 
# 
# google: mapview opacity level 
# 
#    https://r-spatial.github.io/mapview/articles/mapview_02-advanced.html 
#      Ctrl+F: Opacity
mapview(merged_data, zcol = "average", col.regions = brewer.pal(7, "Blues"), alpha.regions = .95)

# at this point, we're pretty close, but it's weird that the Wikipedia map shows us 
# that Telangana has data, but our dataset lacks those data... Oh well.   Not sure we can 
# resolve that since the link referenced seems broken. 

# first I tried something like scale_fill_brewer... then scale_fill_distiller
# then I was confused about direction = -1 and then I got it right iwth 

ggplot(merged_data, aes(fill = average)) + 
  geom_sf(size = 0.25) + 
  scale_fill_fermenter(direction = 1) + 
  cowplot::theme_cowplot() + 
  ggtitle("Literacy rate in India\n2011 Census")


# okay, it's really needless, but i'd love to have a basemap 

# google: adding a basemap in ggplot2 
# 
# https://cengel.github.io/R-spatial/mapping.html#adding-basemaps-with-ggmap 
# 
# chapter 3.4
# looks like ggmap will do what i want 
# 
# okay, i had to register for a google maps api key 
#  i should be set up now 
library(ggmap)

india_bbox <- st_bbox(merged_data)
india_basemap <- get_map(location = c(lon = mean(india_bbox$xmin, india_bbox$xmax)+10, lat = mean(india_bbox$ymin, india_bbox$ymax)+10),
                         zoom = 4, maptype = 'satellite')

ggmap(india_basemap) + 
  geom_sf(data = merged_data, aes(fill = average), size = 0.25, inherit.aes = FALSE, alpha = 0.85) + 
  scale_fill_fermenter(direction = 1) + 
  cowplot::theme_cowplot() + 
  coord_sf(xlim = (india_bbox)[c(1,3)] + c(-5, 5), # min & max of x values
           ylim = (india_bbox)[c(2,4)] + c(-5, 5)) + # min & max of y values
  ggtitle("Literacy rate in India\n2011 Census")

# clearly something is wrong with the projections being mismatched, but resolving
# that would have to be for another day... 
# i would just use the mapview version...
