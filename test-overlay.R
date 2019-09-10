# Aim: get and overlay route network data for schools + commute for a particular area
#test edit
library(dplyr)

#EPSG:27700 is the code for the British National Grid. So after getting the IoW route network this then transforms it to the British National Grid, so that distances are specified in metres instead of degrees latlong
rnet_commute = pct::get_pct_rnet(region = "isle-of-wight") %>% sf::st_transform(27700)
rnet_schools = pct::get_pct_rnet(region = "isle-of-wight", purpose = "school") %>% sf::st_transform(27700)

schools = sf::read_sf("https://github.com/npct/pct-outputs-national/raw/master/school/lsoa/d_all.geojson") %>% sf::st_transform(27700) 
schools = schools %>% filter(lad_name == "Isle of Wight")

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
  mapview::mapview(schools) 
  


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

##########Combining the schools and commuter route networks###
commute_less = rnet_commute[,c(1,6,8,9)]
schools_less = rnet_schools[,c(1,5,6,7)]
combine = rbind(commute_less,schools_less)
summary(combine)

rnet_combined = stplanr::overline2(x = combine, attrib = "dutch_slc")

rnet_combined$color = cut(x = rnet_combined$dutch_slc, breaks = breaks, labels = colors)
rnet_combined$color = as.character(rnet_combined$color)

plot(rnet_combined$geometry, col = rnet_combined$color)

par(mfrow = c(2,2))
plot(rnet_commute$geometry, col = rnet_commute$color,main = "Commute")
plot(rnet_schools$geometry, col = rnet_schools$color,main = "Schools")
plot(rnet_combined$geometry, col = rnet_combined$color,main = "Combined")

###A 1km raster based on the combined route network#####
raster1km_combined_mean = raster::rasterize(x = rnet_combined, y = r, field = "dutch_slc", fun = mean)

mapview::mapview(raster1km_combined_mean) +
  mapview::mapview(schools) 

##Using length of routes instead of mean value for raster function###
raster1km_combined_length = raster::rasterize(x = rnet_combined, y = r, field = "dutch_slc", fun = length)

mapview::mapview(rnet_combined_raster) 

##Using length of routes multiplied by mean value for raster function###

IoW1km_combined_lxm = raster::rasterize(x = rnet_combined, y = r, field = "dutch_slc", fun=function(x,...){return(length(x)*mean(x))})

mapview::mapview(IoW1km_combined_lxm)

###Not necessary###
#library(rgdal)
#library(raster)
#raster1km_calc = overlay(raster1km_combined_mean,raster1km_combined_length,fun=function(r1, r2){return(r1*r2)})

#mapview::mapview(raster1km_calc) 


##Using length of routes with 200m resolution###
r200 = raster::raster(rnet_commute, resolution = 200)
rnet_combined_raster200 = raster::rasterize(x = rnet_combined, y = r200, field = "dutch_slc", fun = length)
mapview::mapview(rnet_combined_raster200) 
     