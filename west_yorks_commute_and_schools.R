setwd("../GitHub/pct-commute-schools-overlay")
setwd("\\\\ds.leeds.ac.uk/staff/staff7/geojta/GitHub/pct-commute-schools-overlay")
readRDS("rnet_full.Rds")

readRDS("l.Rds")
readRDS(".Rds")
readRDS(".Rds")

points = readRDS("c.Rds")
mapview::mapview(points)

desire_lines = readRDS("l.Rds")
mapview::mapview(desire_lines)

schools_rnet = readRDS("\\\\ds.leeds.ac.uk/staff/staff7/geojta/GitHub/pct-commute-schools-overlay/Schools/rnet_full.Rds") %>% sf::st_transform(27700)


breaks = c(-1, 10, 50, 100, 500, 1000)
colours = sf::sf.colors(n=length(breaks) - 1)
schools_rnet$colour = cut(x = schools_rnet$dutch_slc, breaks = breaks, labels = colours)


