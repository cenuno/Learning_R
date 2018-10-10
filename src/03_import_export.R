#
# Author:   Cristian E. Nuno
# Purpose:  Importing data from the internet and exporting as .csv/.rds file
# Date:     October 3, 2018
#

# load necessary packages ----
library(here)
library(rgdal)
library(tidyverse)

# load necessary data ----
# note: we will be using the Chicago Public Schools (CPS)
#       School Profile Information SY1617 data set from
#       the City of Chicago data portal.
#       for meta data, please see: https://data.cityofchicago.org/Education/Chicago-Public-Schools-School-Profile-Information-/8i6r-et8s
df <-
  read_csv(file = "https://data.cityofchicago.org/api/views/8i6r-et8s/rows.csv?accessType=DOWNLOAD")


# download the 77 Chicago community area shapefile
# note: this GeoJSON shapefile is from the City of Chicago data portal.
#       for meta data, please see: https://data.cityofchicago.org/Facilities-Geographic-Boundaries/Boundaries-Community-Areas-current-/cauq-8yn6
cca <- readOGR(dsn = "https://data.cityofchicago.org/api/geospatial/cauq-8yn6?method=export&format=GeoJSON"
               , stringsAsFactors = FALSE)


# export data -----
write_csv(df, path = here("raw_data", "cps_sy1617_school_profiles.csv"))

# this an R object that is smaller in file size than a .csv
# for more info, see ?serialize and ?saveRDS
saveRDS(df, file = here("raw_data", "cps_sy1617_school_profiles.rds"))

saveRDS(cca, file = here("raw_data", "chicago_community_areas.rds"))

# end of script #
