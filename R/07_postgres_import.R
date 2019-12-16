#
# Author:     Cristian E. Nuno
# Purpose:    Import postgres into R
# Date:       December 16, 2019
#

# install necessary packages ----
install.packages(c("DBI", "RPostgres"))

# load necessary packages -----
library(DBI)
library(here)
library(tidyverse)

# Connect to a specific postgres database
con <- dbConnect(RPostgres::Postgres(),
                 dbname = "chicago", 
                 host = "localhost", 
                 port = 5432) 

# list available tables ----
dbListTables(con)

# store one table as a tibble ----
cps_dropout_rates_df = 
  dbReadTable(con, "cps_dropout_rate_2011_2019") %>%
  as_tibble()

# store cps school, sy1617, info ----
cps_schools_sy1617_df = 
  readRDS(here("raw_data", "cps_sy1617_school_profiles.rds"))

# limit data to only those are from 2017 and whose schools are not closed ----

# create a new tibble that only contains the 
# - school_id, total student count, and dropout rate
# note: some records will be dropped, be sure to note which ones do get dropped

# create a scatter plot that visualizes the relationship between 
# total student count per school and the dropout rate ----


