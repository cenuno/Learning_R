#
# Author:   Cristian E. Nuno
# Purpose:  Introduction to ggplot2, part 1
# Date:     October 3, 2018
#

# load necessary packages ----
library(here)
library(tidyverse)

# load necessary data ----
df <- readRDS(here("raw_data", "cps_sy1617_school_profiles.rds"))

# 1. last week we were able to answer the following question ------
# For each type of `ADA_Accessible` value,
# what is the distribution of `Overall_Rating`?
ada.overall.counts <- 
  df %>%
  count(ADA_Accessible, Overall_Rating) %>%
  group_by(ADA_Accessible) %>%
  mutate(total_n = sum(n), pct = n / total_n) %>%
  ungroup() %>%
  # here we have to enforce order with this variable
  mutate(Overall_Rating = factor(Overall_Rating
                                 , levels = c("Level 1+"
                                              , "Level 1"
                                              , "Level 2+"
                                              , "Level 2"
                                              , "Level 3"
                                              , "Inability to Rate")))

# 2. visualizing this data frame requires us to know a few things ----
# * what's the y-axis?
# * what's the x-axis?
# * what type of geometry do we want to us?
# * what groups do we want to show?
# * how will color be determined?
#
# the answers to these questions are supplied inside of aes()
# a function that maps variables to visual properties inside of your ggplots
# * what's the y-axis? --> percentage of each type of ADA_Accessible value by its Overall_Rating value
# * what's the x-axis? --> each type of ADA_Accessible value
# * what type of geometry do we want to us? --> let's be boring and do a bar plot
# * what groups do we want to show?  --> Overall_Rating for each type of ADA_Accessible value
# * how will color be determined? --> Overall_Rating values
p <- 
  ada.overall.counts %>%
  ggplot(aes(x = ADA_Accessible
             , y = pct
             , fill = Overall_Rating
             , group = Overall_Rating))

# view initial result ----
p

# that blank screen is a result of no geometry being supplied ---
# building elements onto your ggplot requires the use of '+' rather than %>%
p + geom_col()

# okay...looks like we have a stacked bar chart with some funky colors ----
# let's try unstacking the bars
p + geom_col(position = "dodge")

# how do we manually change the colors? ---
p +
  geom_col(position = "dodge") +
  scale_fill_manual(values = c("#709d4d", "#a0ce66"
                               , "#fec325", "#e03526"
                               , "#801113", "#cccccc"))

# how do we add labels? ----
p +
  geom_col(position = "dodge") +
  scale_fill_manual(values = c("#709d4d", "#a0ce66"
                               , "#fec325", "#e03526"
                               , "#801113", "#cccccc")) +
  xlab("ADA Accessibility") +
  ylab("Percentage of Schools") +
  labs(title = "Comparing ADA Accessibilty by Overall Ratings, SY1617"
       , caption = "Source: CPS SY1617 School Profile")

# end of script #
