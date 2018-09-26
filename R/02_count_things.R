#
# Author:   Cristian E. Nuno
# Purpose:  Counting Groups of Things in R
# Date:     September 26, 2018
#

# Welcome message: --------
#
# Today's class will be about the wonderful world of counting groups of things in R.
#

# remove all objects in the Global Environment -----
rm(list = ls())

# install necessary packages -----------
install.packages(c("RCurl", "openxlsx"))

# load necessary packages ----------
# note: if you don't have this package, run:
# install.packages("tidyverse")
library(openxlsx)  # simplifies the process of writing and styling Excel files in R
library(RCurl)     # general network client interface for R
library(tidyverse) # set of packages that work in harmony for visualization, data wrangling, functional programming in R

# load necessary functions -------
SourceGithub <- function(x) {
  # Input:
  #   * x: a url to the raw source of code on GitHub
  #
  # Output: runs/evaluates/compiles the source code in your Global Environment
  require(RCurl) 
  
  # read script lines from x
  script <- getURL(x, ssl.verifypeer = FALSE)
  
  # evaluate script in the Global Environment
  eval(parse(text = script), envir = .GlobalEnv)
}

# source the ExportXLSX() function from GitHub -----
SourceGithub("https://gist.githubusercontent.com/cenuno/268b1e2beccb79b2149e80bd2eeea685/raw/87efc313fcead170bc8997e8ee6fcad3b829b05d/Export_XLSX.R")

# load necessary data --------------
# note: we will be using the Chicago Public Schools (CPS)
#       School Profile Information SY1617 data set from
#       the City of Chicago data portal.
#       for meta data, please see: https://data.cityofchicago.org/Education/Chicago-Public-Schools-School-Profile-Information-/8i6r-et8s
df <-
  read_csv(file = "https://data.cityofchicago.org/api/views/8i6r-et8s/rows.csv?accessType=DOWNLOAD")

# 1. Last week, you were introduced to the pipe operator - %>% ------
#    to take something on the left-hand side and apply something to it on the right-hand side
#    i.e. ingredients %>% MakePizza() would return a pizza. 
#
#    This week, we want to get comfortable counting things.
#
#    Before we start, remember to examine the contents of your data frame first
glimpse(df)

#    Okay, it looks like each column represents some variable for each of the 661
#    CPS schools from SY1617.

# 2. This week, let's count the values in few columns: -------
df %>%
  count(School_Type) %>%
  View("School Types, SY1617")

# note: if you wanted to return the table in descending order
#       set the 'sort' argument equal to TRUE
df %>%
  count(School_Type, sort = TRUE) %>%
  View("School Types (Descending), SY1617")

df %>%
  count(ADA_Accessible) %>%
  View("ADA Accessibilities, SY1617")

df %>%
  count(Overall_Rating) %>%
  View("Overall Rating, SY1617")

df %>%
  count(Rating_Statement) %>%
  View("Rating Statement, SY1617")

# 3. count() can take multiple columns ----------

# here, we see that each value of `Overall_Rating` 
# is mapped to one and only one value in `Rating_Statement`
df %>%
  count(Overall_Rating, Rating_Statement) %>%
  View("Overall Rating & Rating Statement, SY1617")

# here, we see that every value of `ADA_Accessible`
# contains at least one value in `Rating_Statement`
df %>%
  count(ADA_Accessible, Overall_Rating) %>%
  View("ADA Accessibility & Overall Rating, SY1617")

# 4. But what if we were interested in doing group calculations?
#    By using %>%, we can do this all in one call.
#
#    We'll need to use group_by() and mutate()
#
# 4A. group_by() is used to perform operations on a group level -----
# 
# Here, we should read this as
# * Within `df`
# * group by the `ADA_Accessible` column
# * summarize the number of records associated with each group in the `ADA_Accesible` column
df %>%
  group_by(ADA_Accessible) %>%
  summarize(n = n()) %>%
  View("What is happening under the hood with count()")

# 4B. mutate() is used to create a new column using data within a data frame ----
df %>%
  count(ADA_Accessible) %>%
  mutate(total_n = sum(n)
         , pct   = n / total_n) %>%
  View("'total_n' sums 'n' and 'pct' divides 'n' by 'total_n'")

# Now, we can answer the following question: ----------
# For each type of `ADA_Accessible` value,
# what is the distribution of `Overall_Rating`?
ada.overall.counts <- 
  df %>%
  count(ADA_Accessible, Overall_Rating) %>%
  group_by(ADA_Accessible) %>%
  mutate(total_n = sum(n), pct = n / total_n) %>%
  ungroup()

# export results -----
ExportXLSX(named.list = list("ADA Counts by Rating" = ada.overall.counts)
           , name.of.file = "ada_counts.xlsx")

# view results
openXL("ada_counts.xlsx")

# end of script #
