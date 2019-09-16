# Aim: get and overlay route network data for schools + commute for a particular area
library(dplyr)
library(sf)

###Changed from Isle-of-Wight to west-yorkshire
rnet_commute = pct::get_pct_rnet(region = "west-yorkshire") %>% sf::st_transform(27700)
rnet_schools = pct::get_pct_rnet(region = "west-yorkshire", purpose = "school") %>% sf::st_transform(27700)

schools = sf::read_sf("https://github.com/npct/pct-outputs-national/raw/master/school/lsoa/d_all.geojson") %>% sf::st_transform(27700) 
wyorks = c("Leeds", "Bradford", "Kirklees", "Wakefield", "Calderdale")
schools = schools %>% filter(lad_name %in% wyorks)

##z = pct::get_pct_zones("hereford-and-worcester", geography = "lsoa")
z = pct::get_pct_zones("west-yorkshire", geography = "lsoa")

breaks = c(-1, 10, 50, 100, 500, 1000, 5000)
colors = sf::sf.colors(n = length(breaks) - 1)

rnet_commute$color = cut(x = rnet_commute$dutch_slc, breaks = breaks, labels = colors)
rnet_commute$color = as.character(rnet_commute$color)

summary(rnet_schools$dutch_slc)
rnet_schools$color = cut(x = rnet_schools$dutch_slc, breaks = breaks, labels = colors)
rnet_schools$color = as.character(rnet_schools$color)

sec_schools = filter(schools, phase == "Secondary")

plot(rnet_commute$geometry, col = rnet_commute$color)
plot(rnet_schools$geometry)
plot(rnet_schools$geometry, col = rnet_schools$color)
plot(schools$geometry, add = TRUE)

# rasterisation of schools route network
r = raster::raster(rnet_commute, resolution = 1000)
# Note: the next line is sloooow, even for small region of IoW and with low spatial resolution (1 km)
rnet_schools_raster = raster::rasterize(x = rnet_schools, y = r, field = "dutch_slc", fun = mean)

# test with terra
devtools::install_github("rspatial/terra")

mapview::mapview(rnet_schools_raster) 
  mapview::mapview(sec_schools) +
  mapview::mapview(z)

saveRDS(rnet_schools_raster, file = "wyorks_schools_raster.rds")

# rasterisation of commute route network
rnet_commute_raster = raster::rasterize(x = rnet_commute, y = r, field = "dutch_slc", fun = mean)
mapview::mapview(rnet_commute_raster) +
  mapview::mapview(sec_commute) 
  mapview::mapview(z)


# ideas/next steps (could become github issues)
# do the same for commute layer
# try a different function. Mean doesn't work well - it produces the highest values in squares that only contain one road (eg near Ilkley). Could include length or length * n_cycling or number of segments or number of segments * mean
# Idea: find cells that are above a threshold value in both schools and commute layers
# Filter out single or double isolated pixels to identify routes where there is overlap
# https://cran.r-project.org/web/packages/imager/vignettes/pixsets.html
# Is this possible? Check methods
# Update school origin-destination data
# Data at higher resolution?
# New primary schools? Ask Martin
  
####Create a combined route network########
commute_less = rnet_commute[,c(1,6,8,9)]
schools_less = rnet_schools[,c(1,5,6,7)]

combine = rbind(commute_less,schools_less)
summary(combine)

###Creating the route network###
rnet_combined = stplanr::overline2(x = combine, attrib = "dutch_slc")

rnet_combined$color = cut(x = rnet_combined$dutch_slc, breaks = breaks, labels = colors)
rnet_combined$color = as.character(rnet_combined$color)
plot(rnet_combined$geometry, col = rnet_combined$color)

###Create 1km raster for the combined route network, fun=length###
rnet_combined_raster = raster::rasterize(x = rnet_combined, y = r, field = "dutch_slc", fun = length)
mapview::mapview(rnet_combined_raster) 

###Create 200m raster for the combined route network, fun=length###
r200 = raster::raster(rnet_commute, resolution = 200)
rnet_combined_raster200 = raster::rasterize(x = rnet_combined, y = r200, field = "dutch_slc", fun = length)
mapview::mapview(rnet_combined_raster200) 

###Create 200m raster for the combined route network, fun=mean###
raster200m_combined_mean = raster::rasterize(x = rnet_combined, y = r200, field = "dutch_slc", fun = mean)
mapview::mapview(raster200m_combined_mean) 

##Calculate length*mean for a 200m raster###
wyorks200m_combined_lxm = overlay(rnet_combined_raster200,raster200m_combined_mean,fun=function(r1,r2){return(r1*r2)})
mapview::mapview(wyorks200m_combined_lxm)

###Create 100m raster for the combined route network, fun=length###
r100 = raster::raster(rnet_commute, resolution = 100)
wyorks100m_combined_length = raster::rasterize(x = rnet_combined, y = r100, field = "dutch_slc", fun = length)
mapview::mapview(wyorks100m_combined_length) 

###Create 100m raster for the combined route network, fun=mean###
wyorks100m_combined_mean = raster::rasterize(x = rnet_combined, y = r100, field = "dutch_slc", fun = mean)
mapview::mapview(wyorks100m_combined_mean) 

##Calculate length*mean for a 100m raster###
wyorks100m_combined_lxm = raster::rasterize(x = rnet_combined, y = r100, field = "dutch_slc", fun = function(x,...){return(length(x)*mean(x))})
#wyorks100m_combined_lxm = overlay(wyorks100m_combined_length,wyorks100m_combined_mean,fun=function(r1,r2){return(r1*r2)})
mapview::mapview(wyorks100m_combined_lxm)
#writeRaster(wyorks200m_combined_lxm,"wyorks200m_combined_lxm.tiff")

##Plot the combined vector map just for central Leeds###
library(ggplot2)
ggplot() + geom_sf(data = rnet_combined$geometry, col = rnet_combined$color) + coord_sf(xlim = c(427000,431000),ylim = c(432000,436000),expand = FALSE) + theme_bw()

##Plot the schools only vector map just for central Leeds
###Added schools point data
breaks = c(-1, 10, 50, 100, 500, 1000, 5000)
colors = sf::sf.colors(n = length(breaks) - 1)

###Putting schools on a route network map
plot(rnet_schools$geometry,col = rnet_schools$color)
plot(schools,add = TRUE)

heavy_schools = rnet_schools[rnet_schools$dutch_slc>100,]
plot(heavy_schools$geometry,col = heavy_schools$color)
plot(schools,add = TRUE)

##ggplot for schools, plus version for heavily used routes only##
library(ggplot2)
ggplot() + geom_sf(data = rnet_schools$geometry, col = rnet_schools$color) + geom_sf(data = schools) + coord_sf(xlim = c(427000,431000),ylim = c(432000,436000),expand = FALSE) + theme_bw()

ggplot() + geom_sf(data = heavy_schools$geometry, col = heavy_schools$color) + geom_sf(data = schools) + coord_sf(xlim = c(427000,431000),ylim = c(432000,436000),expand = FALSE) + theme_bw()

##same for whole of west yorkshire
ggplot() + geom_sf(data = rnet_schools$geometry, col = rnet_schools$color) + geom_sf(data = schools) + theme_bw()

ggplot() + geom_sf(data = heavy_schools$geometry, col = heavy_schools$color) + geom_sf(data = schools) + theme_bw()


##Tmap##creating xlim and ylim data sets
leeds_centre = st_bbox(c(xmin = 427000, xmax = 431000, ymin = 432000, ymax = 436000), crs = st_crs(rnet_schools)) %>%
                         st_as_sfc()

library(tmap)
leeds_map = tm_shape(rnet_schools, bbox = leeds_centre) + tm_lines(col = rnet_schools$color) 



         