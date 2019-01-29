#
# Author:   Cristian E. Nuno
# Purpose:  Introduction to ggplot2, part 2
# Date:     October 10, 2018
#

# install necessary packcages -----
install.packages(c("broom", "formattable", "rgdal"))

# load necessary packages ----
library(broom)
library(formattable)
library(here)
library(rgdal)
library(tidyverse)

# load necessary data ----

# load cps sy1617 school profile data
caption.text <- "Source: City of Chicago Data Portal"

df <- 
  readRDS(here("raw_data", "cps_sy1617_school_profiles.rds")) %>%
  # change Inability to Rate to Unable to Rate
  mutate(Overall_Rating = if_else(Overall_Rating == "Inability to Rate"
                                  , "Unable to Rate"
                                  , Overall_Rating)
         # casting Overall_Rating as a factor
         # with specific ordering
         , Overall_Rating = factor(Overall_Rating
                                   , levels = c("Level 1+"
                                                , "Level 1"
                                                , "Level 2+"
                                                , "Level 2"
                                                , "Level 3"
                                                , "Unable to Rate")))

# load chicago 77 community areas shapefile
cca <- readRDS(here("raw_data", "chicago_community_areas.rds"))

# 1. last week we were able to answer the following question ------
#    What values do I want to mapped onto the plot?
#    i.e. what value defines the x-axis? the y-axis? any groups?
overall.rating <-
  df %>%
  count(Overall_Rating) %>%
  mutate(total_n = sum(n), pct = n / total_n)

# plot Overall_Rating labels on x-axis, and their pct's on the y-axis ----
overall.rating %>%
  ggplot(aes(x = Overall_Rating
             , y = pct
             # specify that we want the bars to be colored differently
             , fill = Overall_Rating
             # we want the value of pct to be printed on each bar
             , label = percent(pct, digits = 0))) +
  geom_col() + 
  # for each pct value, print it within the bar and just above the top
  geom_text(position = position_dodge(width = 0.9), vjust = -0.5) +
  # these values come from the CPS school profiles website
  # see the 'School Rating' question mark
  # https://schoolinfo.cps.edu/schoolprofile/schooldetails.aspx?SchoolId=609864
  scale_fill_manual(values = c("#709d4d", "#a0ce66"
                               , "#fec325", "#e03526"
                               , "#801113", "#cccccc")) +
  # change the y-axis so that is easier to read the percentages
  scale_y_continuous(labels = function(x) paste0(x * 100, "%")) +
  # rename the legend title
  guides(fill = FALSE) +
  xlab("Overall Rating") +
  ylab("Percentage of SY1617 Schools") +
  labs(title = "Over 60% of CPS schools recieved the a high rating of Level 1 or higher, SY1617"
       , caption = caption.text) +
  theme_minimal() +
  # keep only the major y axis gridlines
  theme(panel.grid.major.x = element_blank()
        , panel.grid.minor.y = element_blank()) +
  # save the results
  # note: by default, ggsave() will save the plot in the same dimensions
  #       as those in your plot viewer tab. You may override that by
  #       supplying dimensions
  ggsave(filename = here("visuals", "overall_rating_sy1617.png"))
  
# 2. This week, let's learn how to plot a shape file using ggplot ---
#    note: for more information on tidying a spatial polygon data frame
#          see: https://broom.tidyverse.org/reference/sp_tidiers.html
cca.plottable <- 
  tidy(cca, region = "community") %>%
  mutate(id = str_to_title(id))

# plot the city of chicago ---
cca.plottable %>%
  ggplot(aes(x = long, y = lat, group = group)) +
  # color the borders of each cca with a light gray color
  geom_polygon(color = "#808080") + 
  coord_map() +
  # hide non helpful plot elements
  theme(axis.title = element_blank()
        , axis.text = element_blank()
        , axis.ticks = element_blank()
        , panel.grid = element_blank()
        , panel.background = element_blank()) +
  labs(title = "Map of Chicago"
       , caption = caption.text) +
  ggsave(filename = here("visuals", "map_of_chicago.png"))

# 3. to plot only a few community areas of interest, subset cca.plottable ---
few.cca <- 
  c("Near West Side", "Lower West Side", "South Lawndale"    
    , "North Lawndale", "East Garfield Park", "West Garfield Park"
    , "Mckinley Park", "Bridgeport", "Armour Square")

few.cca.plottable <-
  cca.plottable %>%
  filter(id %in% few.cca) %>%
  # highlight the lower west side chicago blue; all other gray
  mutate(highlight_colors = if_else(str_detect(id, "Lower West Side")
                                    , "#C0E6F5"
                                    , "#413D33"))

# plot results --------------
few.cca.plottable %>%
  ggplot(aes(x = long
             , y = lat
             , group = group
             , color = id
             , fill = id)) +
  geom_polygon(color = "#808080") +
  coord_map() +
  # for each unique cca, supply the highlight_color
  scale_color_manual(values = few.cca.plottable %>% 
                       distinct(id, highlight_colors) %>%
                       pull(highlight_colors)) +
  scale_fill_manual(values = few.cca.plottable %>% 
                      distinct(id, highlight_colors) %>%
                      pull(highlight_colors)) +
  guides(color = FALSE, fill = guide_legend(title = "Community Areas")) +
  # hide non helpful plot elements
  theme(axis.title = element_blank()
        , axis.text = element_blank()
        , axis.ticks = element_blank()
        , panel.grid = element_blank()
        , panel.background = element_blank()) +
  labs(title = "Focus the audience's attention on one particular polygon"
       , caption = caption.text) +
  ggsave(filename = here("visuals", "lower_west_side_highlight.png"))


# end of script #
