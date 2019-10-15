# Aim - find the route segment with the highest school cycle potential

rnet = readRDS("heavy_schools-wy-100+godutch.Rds")

rnet_ordered = rnet[order(rnet$dutch_slc, decreasing = TRUE),]
head(rnet_ordered)

length_segment = st_length(rnet_ordered)


dd=200
units(dd) = units(length_segment)

long = rnet_ordered %>% filter(length_segment > dd)

mapview(long)
dim(rnet)
class(rnet)

mapview(long[1:10,])
