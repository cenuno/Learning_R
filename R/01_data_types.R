#
# Author:   Cristian E. Nuno
# Purpose:  Intro to Data Types in R
# Date:     September 19, 2018
#

# Welcome message:
#
# Hello! Thanks for taking this course. To run lines in R, hit Ctrl + Enter.


# remove all objects in the Global Environment -----
rm(list = ls())

# install necessary packages -------
# note: this is done once and only once
#       after this is done, feel free to comment the following line out
install.packages("tidyverse")

# load necessary packages ----------
library(tidyverse)

# load necessary data --------------
# note: we will be using the Chicago Public Schools (CPS)
#       School Profile Information SY1617 data set from
#       the City of Chicago data portal.
#       for meta data, please see: https://data.cityofchicago.org/Education/Chicago-Public-Schools-School-Profile-Information-/8i6r-et8s
cps_skools <-
  read_csv(file = "https://data.cityofchicago.org/api/views/8i6r-et8s/rows.csv?accessType=DOWNLOAD")

# 1. What just happened? ------
#
#    cps_skools is now an object in the Global Environment that transforms
#    the data from the portal into a tibble/data frame/table.

class(cps_skools) # [1] "tbl_df"     "tbl"        "data.frame"

# 2. What is a tibble? Are you speaking english? -----
#
#    A tibble is a friendlier version of a data.frame, which is a 
#    list of variables of the same number of rows.
#
#    What makes tibble objects friendlier is that it only outputs 
#    the first 10 rows; whereas a data frame will freeze your computer
#    by returning all the records.

cps_skools # note: isn't that friendly looking?

cps_skools %>% as.data.frame() # note: isn't that non-sensical?

# 3. I see text down below. What is that? ------
#
#    That is the console! That is where R code gets compiled from
#    akward verbs - i.e. functions() - and returns the output.

# 4. What do you mean return output? Can I store output? ------
#
#    The console compiles the code, but it does not store the output.
#    Instead, you must store it by using the assignment operator: <-.

cps_skools %>% nrow() # note: the console returned 661

n_row <- cps_skools %>% nrow() # note: the console returned nothing.

# 5. Wait. Slow down. What the heck is %>%? --------
#
#    %>% is the pipe-operator. For me, it is my favorite part of the R language.
#    You should read %>% as take from the left-hand side and apply 
#    something from the right-hand side.
#
#    To create the pipe operator, simply use Ctrl+Shift+m
#
# cps_skools is our tibble
# and we want to apply the nrow() function on it
# to find out the number of rows it contains.
cps_skools %>% nrow() # note: the console returned 661

#    While it is uncomfortable at first, the increase in readability
#    is incredible when you start doing data science.

# 6. Hey...cps_skools and n_row is appearing on the right hand corner. Why? -------
#
#    R is an object-orientied programming language. That's nerd for
#    saying you - and you alone - are responsible for naming objects
#    in your global environment.
#
#    To help you navigate all of your objects, the top right hand
#    panel contains a few tabs, none more important than the 
#   'Environment' tab. 

objects() # [1] "cps_skools" "n_row"

# 7. Dude, can we please fix your spelling?
#
#    Yes we can. 

# 1) store cps_schools in a new object
cps_schools <- cps_skools

# 2) remove cps_skools from the global environment
cps_skools %>% rm()


# 3) check your work
objects()
cps_schools %>% dim() # [1] 661  91

# 8. I want to see the data. ----------
#
#    Not a problem, take advantage of the View() function
cps_schools %>%
  View(title = "Viewing CPS SY1617 School Profiles")

# 9. Hey this looks like Excel! -----
#
#    While View() offers a great way to see the data,
#    glimpse() providers a better way to see what kinds of data
#    exist within the tibble.
cps_schools %>% glimpse()
# Observations: 661
# Variables: 91
# $ School_ID                               <int> 610158, 610282, 609996, 400...

#    As you'll see, glimpse() returns a few things:
#    - the number of observations (i.e. rows)
#    - the number of variables (i.e. columns)
#    - each variable's type (<int>) followed by
#    - the first few values

# 10. Why are data types important? ---------
#
#     Because some functions only take certain types of objects!
cps_schools %>%
  pull(Is_High_School) %>%
  mean() # note: you can't take the mean() of a character vector

cps_schools %>%
  pull(Student_Count_Low_Income) %>%
  mean() # note: but you can for those vectors which are int/numeric/double

# 11. What the heck is a vector? -----------
#
#     A vector is formal name for a variable or a column.
#     In section 10, the variable "Is_High_School" is a character vector
cps_schools %>% 
  pull(Is_High_School) %>% 
  class()

# whereas the "Student_Count_Low_Income" column is an integer vector
cps_schools %>%
  pull(Student_Count_Low_Income) %>%
  class()

# 12. So can you count character vectors? -----
#
#     Yes you can.
cps_schools %>%
  count(School_Type, sort = TRUE) %>%
  View("Counting the number of CPS schools by school type")

# end of script #
