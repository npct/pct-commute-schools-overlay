#Built-up area data from https://data.gov.uk/dataset/c8fa0436-5cc4-4b8f-90ea-e863c17213cb/built-up-area-sub-divisions-december-2011-boundaries

builtup = sf::read_sf("https://github.com/npct/pct-commute-schools-overlay/raw/master/Builtup_Area_Sub_Divisions_December_2011_Boundaries.geojson")
mapview::mapview(builtup)

built = sf::read_sf("https://github.com/npct/pct-commute-schools-overlay/raw/master/Builtup_Areas_December_2011_Boundaries_V2.geojson")
mapview::mapview(built)
