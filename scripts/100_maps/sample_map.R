


setwd("/data/gent/vo/001/gvo00125/vsc44392/Projects/North_Sea_Viral_Metagenomics/working/100_maps")

library(tidyverse)
library(maps)
library(httpgd)
hgd()

coordinates <- read.csv("/data/gent/vo/001/gvo00125/vsc44392/Projects/North_Sea_Viral_Metagenomics/data/sample_overview/sample_coordinates.csv")

# Selecting cruises

coordinates <- coordinates %>%
    dplyr::filter(cruise %in% c("PE477", "PE486", "NIOZ_Jetty", "GF2018"))

coordinates <- coordinates %>%
    mutate(label_number = row_number())  # Create a numeric label based on row number


# Create a basic map of the world or specific region (like Europe)
world_map <- map_data("world")

# Plot the points on the map using ggplot2
ggplot() +
  # Add the map
  geom_polygon(data = world_map, aes(x = long, y = lat, group = group), fill = "lightblue", color = "white") +
  # Add the points from your dataset
  geom_point(data = coordinates, aes(x = longitude, y = latitude, color = cruise), size = 2) +
  # Optionally, add labels for the sample points
  geom_text(data = coordinates, aes(x = longitude, y = latitude, label = sample_name), hjust = 1.2, vjust = 0.5, size = 3) +
  # Set limits to zoom in on the region of interest
  coord_quickmap(xlim = c(-3, 6), ylim = c(50, 57)) +
  # Add labels
  labs(title = "Sample Locations on Map", x = "Longitude", y = "Latitude") +
  theme_minimal()

