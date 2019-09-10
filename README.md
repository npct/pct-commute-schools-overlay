Methods to identify safe routes to schools in residential areas
================

<!-- README.md is generated from README.Rmd. Please edit that file -->

# Introduction

<!-- badges: start -->

<!-- badges: end -->

The goal of pct-commute-schools-overlay is to explore to identify
residential zones that would be served by a major safe route to school.

The outputs should provide evidence in support of ‘liveable streets’,
where the emphasis is on reducing car vehicle speeds and volumes and
‘filtered permeability’, where through traffic is allowed for cycling
and walking, but not driving.

## Methods

Vector and raster approaches were explored, as illustrated in Figure
@ref(fig:combi1).

<img src="combined rnet.png" title="Demonstration of vector vs raster representations of combined commute/school travel route networks in sample region (West Yorkshire)." alt="Demonstration of vector vs raster representations of combined commute/school travel route networks in sample region (West Yorkshire)." width="50%" /><img src="combined rnet 1km raster.png" title="Demonstration of vector vs raster representations of combined commute/school travel route networks in sample region (West Yorkshire)." alt="Demonstration of vector vs raster representations of combined commute/school travel route networks in sample region (West Yorkshire)." width="50%" />

This shows the aggregation effect of rasterising the road data. At a
higher resolution, we can see how individual roads are lost, but the
overall picture is
retained.

<img src="combined_rnet_leeds_centre.png" title="The vector route network, 100m and 200m resolution raster images for the centre of Leeds, showing the combined commute/school travel networks." alt="The vector route network, 100m and 200m resolution raster images for the centre of Leeds, showing the combined commute/school travel networks." width="33%" /><img src="100m_clxm_leeds_centre.png" title="The vector route network, 100m and 200m resolution raster images for the centre of Leeds, showing the combined commute/school travel networks." alt="The vector route network, 100m and 200m resolution raster images for the centre of Leeds, showing the combined commute/school travel networks." width="33%" /><img src="200m_clxm_leeds_centre.png" title="The vector route network, 100m and 200m resolution raster images for the centre of Leeds, showing the combined commute/school travel networks." alt="The vector route network, 100m and 200m resolution raster images for the centre of Leeds, showing the combined commute/school travel networks." width="33%" />

The starting point therefore is to first identify
