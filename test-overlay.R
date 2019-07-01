# Aim: get and overlay route network data for schools + commute for a particular area
#test edit
library(dplyr)

rnet_commute = pct::get_pct_rnet(region = "isle-of-wight") %>% sf::st_transform(27700)
rnet_schools = pct::get_pct_rnet(region = "isle-of-wight", purpose = "school") %>% sf::st_transform(27700)
schools = sf::read_sf("https://github.com/npct/pct-outputs-national/raw/master/school/lsoa/d_all.geojson") %>% sf::st_transform(27700) 
schools = schools %>% filter(lad_name == "Isle of Wight")
z = pct::get_pct_zones("hereford-and-worcester", geography = "lsoa")
z = pct::get_pct_zones("isle-of-wight", geography = "lsoa")

breaks = c(-1, 10, 50, 100, 500, 1000, 5000)
colors = sf::sf.colors(n = length(breaks) - 1)
rnet_commute$color = cut(x = rnet_commute$dutch_slc, breaks = breaks, labels = colors)
rnet_commute$color = as.character(rnet_commute$color)

summary(rnet_schools$dutch_slc)
rnet_schools$color = cut(x = rnet_schools$dutch_slc, breaks = breaks, labels = colors)
rnet_schools$color = as.character(rnet_schools$color)


plot(rnet_commute$geometry, col = rnet_commute$color)
plot(rnet_schools$geometry)
plot(rnet_schools$geometry, col = rnet_schools$color)
plot(schools$geometry, add = TRUE)

# rasterisation
r = raster::raster(rnet_commute, resolution = 1000)
# Note: the next line is sloooow, even for small region of IoW and with low spatial resolution (1 km)
rnet_schools_raster = raster::rasterize(x = rnet_schools, y = r, field = "dutch_slc", fun = mean)
mapview::mapview(rnet_schools_raster) +
  mapview::mapview(schools) +
  mapview::mapview(z)


# ideas/next steps (could become github issues)
# do the same for commute layer
# could include length or length * n_cycling or number of segments
# Idea: find cells that are above a threshold value in both schools and commute layers
# Filter out single or double isolated pixels to identify routes where there is overlap
# https://cran.r-project.org/web/packages/imager/vignettes/pixsets.html
# Is this possible? Check methods
# Update school origin-destination data
# Data at higher resolution?
# New primary schools? Ask Martin
