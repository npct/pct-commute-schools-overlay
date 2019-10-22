# Aim: get and overlay route network data for schools + commute for a particular area
library(dplyr)
library(sf)
library(ggplot2)
library(pct)
library(raster)
library(mapview)
library(tmap)

###This gets LSOA data (there is no MSOA route network data available for schools)
rnet_commute = pct::get_pct_rnet(region = "west-yorkshire",geography = "lsoa") %>% sf::st_transform(27700)
rnet_schools = pct::get_pct_rnet(region = "west-yorkshire", purpose = "school",geography = "lsoa") %>% sf::st_transform(27700)

schools = sf::read_sf("https://github.com/npct/pct-outputs-national/raw/master/school/lsoa/d_all.geojson") %>% sf::st_transform(27700)
wyorks = c("Leeds", "Bradford", "Kirklees", "Wakefield", "Calderdale")
schools = schools %>% filter(lad_name %in% wyorks)

z = pct::get_pct_zones("west-yorkshire", geography = "lsoa")

breaks = c(-1, 10, 50, 100, 500, 1000, 5000)
colors = sf::sf.colors(n = length(breaks) - 1)

# rnet_commute$color = cut(x = rnet_commute$dutch_slc, breaks = breaks, labels = colors)
# rnet_commute$color = as.character(rnet_commute$color)

# summary(rnet_schools$dutch_slc)
rnet_schools$color = cut(x = rnet_schools$dutch_slc, breaks = breaks, labels = colors)
rnet_schools$color = as.character(rnet_schools$color)



###########Selecting the most heavily used routes to school under Dutch model and 2011##############
##Selecting heavily used routes to school under Dutch model
heavy_schools = rnet_schools[rnet_schools$dutch_slc>100,]
plot(heavy_schools$geometry,col = heavy_schools$color)
plot(schools,add = TRUE)

tmap_mode("view")
tm_shape(heavy_schools) + tm_lines(col = heavy_schools$color)

# heavy_commute = rnet_commute[rnet_commute$dutch_slc>100,]
# plot(heavy_commute$geometry,col = heavy_commute$color)


# ##Selecting heavily used routes to school in 2011
# heavy2011_schools = rnet_schools[rnet_schools$bicycle>5,] %>% na.omit()
# plot(heavy2011_schools$geometry,col = heavy2011_schools$color)
# plot(schools,add = TRUE)

# breaks2011 = c(-1, 1, 5, 10, 50)
# colors2011 = sf::sf.colors(n = length(breaks2011) - 1)
#
# heavy2011_schools$color = cut(x = heavy2011_schools$bicycle, breaks = breaks, labels = colors)
# heavy2011_schools$color = as.character(heavy2011_schools$color)
#
# plot(heavy2011_schools$geometry,col = heavy2011_schools$color)
# plot(schools,add = TRUE)


#########ONS data on builtup areas###########
##Built-up areas
# setwd("~/GitHub/pct-commute-schools-overlay")
# setwd("/home/rstudio/data/npct/pct-commute-schools-overlay")
builtup = sf::read_sf("Builtup_Areas_December_2011_Boundaries_V2.geojson") %>% sf::st_transform(27700)
builtupsub = sf::read_sf("Builtup_Area_Sub_Divisions_December_2011_Boundaries.geojson") %>% sf::st_transform(27700)
# builtup_jun17 = sf::read_sf("Builtup_Areas_December_2011_Boundaries_jun17.geojson") %>% sf::st_transform(27700)



#####LSOA Centroids ######
wyorks_centroids = get_pct_centroids("west-yorkshire",geography = "lsoa") %>% sf::st_transform(27700)

# setwd("\\\\ds.leeds.ac.uk/staff/staff7/geojta/GitHub/pct-commute-schools-overlay/west-yorks")
# wyorks_centroids = readRDS("c.Rds") %>% st_as_sf(wyorks_c)

 ggplot() + geom_sf(data = wyorks_centroids, color = "goldenrod1") + theme_bw()
#
# ggplot() + geom_sf(data = heavy_schools) + geom_sf(data = builtup)

#########Now need to create a raster layer showing number of LSOA centroids within 500m
#create the fishnet
# library(RColorBrewer)
#
# grid <- st_make_grid(wyorks_centroids, cellsize = 500, what = "centers")
# plot(grid)
# dist = st_distance(wyorks_centroids,grid)
# df = data.frame(dist = as.vector(dist)/1000,st_coordinates(grid))
# col_dist = brewer.pal(11,"RdGy")
#
# ggplot(df,aes(X,Y,fill=dist)) +
#   geom_tile() +
#   scale_fill_gradient(colours=rev(col_dist))
################
# grid2 = expand.grid(x = seq(from=410000,to=440000,by=100),y = seq(from=420000,to=447000,by=100))
# grid2 = as.matrix(grid2)


########Plotting distance from LSOA centroids#########
pop_density = raster(xmn = 410000,xmx = 440000,ymn = 420000, ymx = 447000,res = 100)
projection(pop_density) = projection(builtup)

# set.seed(0)
# values(pop_density) = runif(ncell(pop_density))
# hasValues(pop_density)

cgeom = st_coordinates(wyorks_centroids)

# dist_matrix = pointDistance(grid2, cgeom, lonlat = FALSE)
#within500m = dist_matrix[]

#crossdist()

dist_rast = distanceFromPoints(pop_density,cgeom)

#Specify distance from centroids to include
# ex = extract(dist_rast,values(dist_rast)<1000,na.omit=TRUE)
dist_rast[dist_rast>=500] = NA
#Mask distance raster using built-up areas
mdist = mask(dist_rast,builtup)

#Plot raster and LSOA centroids on the same map
mapview(mdist) +
  mapview(wyorks_centroids$geometry)


# ggplot() + geom_raster(data = pop_density, aes(x = x, y = y))

# #500m buffer around schools
# buff = st_buffer(x = schools, dist = 500)
# cont = st_contains(x = wyorks_centroids,y = buff)

##500m buffer around LSOA centroids
lsoa_buff = st_buffer(x = wyorks_centroids, dist = 500)
#now need to mask this for builtup areas only (but the mask() function is for raster objects
res_buff = st_intersection(builtup,lsoa_buff)

mapview(res_buff)

# x2 <- map_lgl(cont, function(x) {
#   if (length(x) == 1) {
#     return(TRUE)
#   } else {
#     return(FALSE)
#   }
# })
#
# ggplot()+geom_sf(data = schools)
#
# ggplot()+geom_sf(data = wyorks_centroids)
#
# ggplot()+geom_sf(data = st_intersection(wyorks_centroids,st_buffer(schools,500)))

#############Vector maps of routes to schools###########
##ggplot for schools in central Leeds##
# library(ggplot2)
# ggplot() + geom_sf(data = builtup) + geom_sf(data = rnet_schools$geometry, col = rnet_schools$color) + geom_sf(data = schools) + coord_sf(xlim = c(427000,431000),ylim = c(432000,436000),expand = FALSE) + theme_bw()
#
# #version for heavily used routes only
# ggplot() + geom_sf(data = heavy_schools$geometry, col = heavy_schools$color) + geom_sf(data = schools) + coord_sf(xlim = c(427000,431000),ylim = c(432000,436000),expand = FALSE) + theme_bw()
#
# ##same for whole of west yorkshire
# ggplot() + geom_sf(data = builtup) + geom_sf(data = rnet_schools$geometry, col = rnet_schools$color) + geom_sf(data = schools) + theme_bw()
#
#heavily used routes again (dutch_slc)
##Create map for Figure 3(i)##will try using tmap so it matches the plot in Figure 3(ii)
ggplot() + geom_sf(data = builtup) + geom_sf(data = builtupsub) + geom_sf(data = heavy_schools$geometry, col = heavy_schools$color) + geom_sf(data = schools) + geom_sf(data = wyorks_centroids, color = "goldenrod1") + coord_sf(xlim = c(410000,440000),ylim = c(420000,447000),expand = FALSE) + theme_bw()

# ##Crop builtup etc##may need to use bbox to set map extent
# builtup_leeds = st_crop(builtup,xmin = 410000,xmax = 440000,ymin = 420000,ymax = 447000)
# box = bb(xlim = c(410000,440000),ylim = c(420000,447000))
#
# tmap_mode("plot")
# builtup_fig = tm_shape(builtup_leeds) + tm_polygons() +
#   tm_shape(builtupsub) + tm_polygons() +
#   tm_shape(wyorks_centroids) + tm_symbols(col = "goldenrod1",scale = 0.4) +
#   tm_shape(schools) + tm_symbols(col="black",scale = 0.4) +
#   tm_shape(heavy_schools) + tm_lines()
# tmap_save(builtup_fig,"schools_and_lsoa.png")

#Intersch clips routes at the boundary of the builtup area.
#Intersch_res clips routes at the boundary of the residential areas (<=500m from an LSOA centroid; masked by built-up areas)

# intersch = st_intersection(heavy_schools,builtup)
intersch_res = st_intersection(heavy_schools,res_buff)


##Extra

# ggplot() + geom_sf(data = builtup) + geom_sf(data = builtupsub) + geom_sf(data = intersch$geometry, col = intersch$color) + geom_sf(data = schools) + coord_sf(xlim = c(410000,440000),ylim = c(420000,447000),expand = FALSE) + theme_bw()
#
# ggplot() + geom_sf(data = builtup) + geom_sf(data = builtupsub) + geom_sf(data = intersch_res$geometry, col = intersch_res$color) + geom_sf(data = schools) + coord_sf(xlim = c(410000,440000),ylim = c(420000,447000),expand = FALSE) + theme_bw()
#
# # ggplot() + geom_sf(data = builtup) + geom_sf(data = builtupsub) + geom_sf(data = coveredsch$geometry, col = coveredsch$color) + geom_sf(data = schools) + coord_sf(xlim = c(410000,440000),ylim = c(420000,447000),expand = FALSE) + theme_bw()
#
# mapview(mdist) + mapview(schools)
# # + mapview(wyorks_centroids, color = "goldenrod1")
#
# + coord_sf(xlim = c(410000,440000),ylim = c(420000,447000),expand = FALSE) + theme_bw()
#
#
# ggplot() + geom_sf(data = builtup) + geom_tile(data = mdist)
#
#
# tmaptools::palette_explorer()

##tmap with builtup areas raster, schools and routes to schools all together##Could find way to edit legend title, have simply removed legend altogether instead
tmap_mode("plot")
res_routes = tm_shape(mdist) + tm_raster(palette = "-Oranges") + tm_layout(legend.show = FALSE) +
  tm_shape(schools) + tm_symbols(col="black",scale = 0.4) +
  tm_shape(intersch_res) + tm_lines()
tmap_save(res_routes,"routes-schools-res.png")

# #heavily used routes again (2011 cycling levels)
# now_school = ggplot() + geom_sf(data = builtup) + geom_sf(data = heavy2011_schools$geometry, col = heavy2011_schools$color) + geom_sf(data = schools) + coord_sf(xlim = c(410000,440000),ylim = c(420000,447000),expand = FALSE) + theme_bw()
# now_school


##Tmap##creating xlim and ylim data sets
# leeds_centre = st_bbox(c(xmin = 427000, xmax = 431000, ymin = 432000, ymax = 436000), crs = st_crs(rnet_schools)) %>%
#   st_as_sfc()



# save results ------------------------------------------------------------

saveRDS(heavy_schools, "heavy_schools-wy-100+godutch.Rds")


