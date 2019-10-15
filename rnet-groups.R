# aim: find groups with high cycling potential

rnet = readRDS("heavy_schools-wy-100+godutch.Rds")
# sln = stplanr::SpatialLinesNetwork(rnet) # fails

# from snet repo, credit: Andrea Gilardi
touching_list = st_touches(rnet)
graph_list = igraph::graph.adjlist(touching_list)
roads_groups = igraph::components(graph_list)
length(roads_groups)
roads_table = table(roads_groups$membership)
roads_table_order = roads_table[order(roads_table, decreasing = TRUE)]
length(roads_table_order)

biggest_group = names(roads_table_order[1])
rnet_single_graph = rnet[roads_groups$membership == biggest_group, ]
plot(rnet$geometry, lwd = 5, col = "grey")
plot(rnet_single_graph$geometry, add = TRUE)

rnet$membership = roads_groups$membership
plot(rnet$geometry, col = rnet$membership)

n = 4
biggest_n_groups = names(roads_table_order[1:n])
rnet$membership_summary = rnet$membership
rnet$membership_summary[rnet$membership_summary == biggest_n_groups[4]] = "4"
rnet$membership_summary[rnet$membership_summary == biggest_n_groups[3]] = "3"
rnet$membership_summary[rnet$membership_summary == biggest_n_groups[2]] = "2"
rnet$membership_summary[rnet$membership_summary == biggest_n_groups[1]] = "1"
plot(rnet$geometry, col = rnet$membership_summary)

# idea: could also be average, or length
tmap_mode("view")
tm_shape(rnet) +
  tm_lines("membership_summary", lwd = "dutch_slc", palette = "Accent", scale = 9)
tmap_save(.Last.value, "Plots/rnet-membership-4-groups.png")
magick::image_read("Plots/rnet-membership-4-groups.png")

rnet_group1 = rnet[rnet$membership == biggest_n_groups[1], ]
tm_shape(rnet_group1) +
  tm_lines("dutch_slc", lwd = "dutch_slc", palette = "viridis", scale = 9) +
  tm_scale_bar()

rnet_group2 = rnet[rnet$membership == biggest_n_groups[2], ]
m = tm_shape(rnet_group2) +
  tm_lines("dutch_slc", lwd = "dutch_slc", palette = "viridis", scale = 9) +
  tm_scale_bar()
tmap_save(m, "rnet-group2.html")
m_image = webshot::webshot("rnet-group2.html", file = "Plots/rnet-group2.png", vwidth = 500, vheight = 400)
magick::image_read("Plots/rnet-group2.png")

##Total length of the top networks######
rnet$segment_length = st_length(rnet)

sum(rnet$segment_length[rnet$membership_summary == 1])
sum(rnet$segment_length[rnet$membership_summary == 2])

##Mean usage of the top networks#####
rnet$weighteduse = rnet$dutch_slc * rnet$segment_length
sum(rnet$weighteduse[rnet$membership_summary == 1])/sum(rnet$segment_length[rnet$membership_summary == 1])
sum(rnet$weighteduse[rnet$membership_summary == 2])/sum(rnet$segment_length[rnet$membership_summary == 2])




