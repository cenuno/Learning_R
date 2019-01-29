#
# Author:   Cristian E. Nuno
# Purpose:  Introduction to ggplot2, part 3
# Date:     October 10, 2018
#

# load necessary packages ----
library(broom)
library(formattable)
library(here)
library(rgdal)
library(tidyverse)

# load necessary data -------

# store caption text
caption.text <- "Source: Chicago Public Schools - School Profile Information SY1617"

# load cps sy1617 school profile data
df <- 
  readRDS(here("write_data", "clean_rating_cps_sy1617_school_profiles.rds")) %>%
  # make all column names lower case
  rename_all(funs(tolower(.)))

# load chicago 77 community areas shapefile
cca <- readRDS(here("raw_data", "chicago_community_areas.rds"))

# squish the shapefile into one record per cca per unique coordinate pair
cca.plottable <- 
  tidy(cca, region = "community") %>%
  mutate(id = str_to_title(id))

# 1. last week we were able to answer the following question ------
#    How do you customize other elements of a ggplot?
#    How can you plot a shapefile using ggplot?

# 2. this week, we're going to learn how to reshape data -----
#
#    this is what 'wide' data looks like
school.population <-
  df %>%
  # return all race/ethnicity columns 
  select(short_name, overall_rating, matches("student_count")) %>%
  # exclude other student populations
  select(-student_count_special_ed, -student_count_english_learners
         , -student_count_low_income)

school.population %>% View("Wide Data")


# verify that all non-Total columns sum up to the total column -----
original.total <- 
  # store the vector in an object
  school.population %>% pull(student_count_total)

derived.total  <- 
  school.population %>% 
  # return all race/ethnicity columns 
  select(-short_name, -overall_rating, -student_count_total) %>%
  # for each row, return the sum
  mutate(total = rowSums(.)) %>%
  pull(total)

all(original.total == derived.total) # [1] TRUE

# we want to reshape school.population such that it has ----
# four columns: name, rating, population, n, and total
school.population.long <-
  school.population %>%
  # remove total column
  select(-student_count_total) %>%
  # gather the race/ethnicity columns into
  # key-value pairs
  gather(key = "population"
         , value = "n"
         , -short_name
         , -overall_rating) %>%
  # replace values in population
  # to be easier to read 
  mutate(population = case_when(
    population == "student_count_black" ~ "Black"
    , population == "student_count_hispanic" ~ "Hispanic"
    , population == "student_count_white" ~ "White"
    , population == "student_count_asian" ~ "Asian"
    , population == "student_count_native_american" ~ "Native American"
    , population == "student_count_other_ethnicity" ~ "Other"
    , population == "student_count_asian_pacific_islander" ~ "Asian Pacific Islander"
    , population == "student_count_multi" ~ "Multi-ethnic"
    , population == "student_count_hawaiian_pacific_islander" ~ "Hawaiian Pacific Islander"
    , population == "student_count_ethnicity_not_available" ~ "Missing"
  )
  # cast population as factor
  # such that 'Other' and 'Missing' appear as the last levels
  , population = factor(population, levels = c("Asian"
                                               , "Asian Pacific Islander"
                                               , "Black"
                                               , "Hawaiian Pacific Islander"
                                               , "Hispanic"
                                               , "Multi-ethnic"
                                               , "Native American"
                                               , "White"
                                               , "Other"
                                               , "Missing"))) %>%
  arrange(overall_rating)

school.population.long %>% View("Long Data")

# any missing values? ---
school.population.long %>% 
  group_by(short_name) %>%
  # testing for 0 or NA
  filter(all(n == 0))

# ah. It seems that YCCS - Virtual has a count of zero 
# this is confirmed on CPS's website
# https://schoolinfo.cps.edu/schoolprofile/schooldetails.aspx?SchoolId=400142

# before visualizing, count how many schools per rating ---
(rating.count <-
    school.population.long %>%
    # keep records that are not YCCS - VIRTUAL
    filter(!short_name == "YCCS - VIRTUAL") %>%
    distinct(short_name, overall_rating) %>%
    count(overall_rating) %>%
    rename(overall_rating_n = n))

# it looks like there are fewer schools in Level 2, Level 3, or Unable to Rate
# keep that in mind

# for each rating
# calculate the average count for each population
rating.population.distribution <-
  school.population.long %>%
  # keep records that are not YCCS - VIRTUAL
  filter(!short_name == "YCCS - VIRTUAL") %>%
  # for each overall rating and population
  # sum the number of students
  group_by(overall_rating, population) %>%
  summarize(overall_n = sum(n)) %>%
  # for each overall rating
  # find the total number of students
  group_by(overall_rating) %>%
  mutate(total_overall_n = sum(overall_n)) %>%
  ungroup() %>%
  # find the percentage of each overall_rating/population pair
  # as a total of all students in each overall_rating
  # note: rounding the percentage to two digits
  mutate(pct = (overall_n / total_overall_n) %>% round(digits = 2)) %>%
  left_join(y = rating.count, by = "overall_rating") %>%
  # create a new column
  # that pastes together the overall rating
  # the number of schools per rating
  mutate(overall_rating_annotated = paste0(overall_rating
                                                  , " (n = "
                                                  , overall_rating_n
                                                  , ")")
         , overall_rating_annotated = factor(overall_rating_annotated
                                             , levels = paste0(rating.count$overall_rating
                                                               , " (n = "
                                                               , rating.count$overall_rating_n
                                                               , ")")))
  
  
# view results ---
rating.population.distribution %>% 
  View("Race/ethnicity per overall rating")

# store the number of schools included in this calculation ---
pop.count <-
  rating.count %>%
  pull(overall_rating_n) %>%
  sum()

# store title
plot.text <-
  paste0("Do higher rated schools have a more diverse student body? (n = "
         , pop.count
         , ")")

# visualize -----
rating.population.distribution %>%
  # note: due to the coord_flip()
  #       'Missing' will appear at the top left hand corner of the y-axis
  #       instead of 'Asian'. To flip the order,
  #       I used reorder() and sorted population in descending order
  ggplot(aes(x = reorder(population, desc(population))
             , y = pct)) +
  # colors taken from this social media post
  # https://twitter.com/ChiPubSchools/status/1052605160579420162/photo/1?ref_src=twsrc%5Etfw%7Ctwcamp%5Eembeddedtimeline%7Ctwterm%5Eprofile%3AChiPubSchools&ref_url=https%3A%2F%2Fcps.edu%2FPages%2Fhome.aspx
  geom_col(fill = "#4e8ed8") +
  ylab("Percentage") +
  xlab("Race/Ethnicity Population") +
  scale_y_continuous(labels = function(x) paste0(x * 100, "%")) +
  coord_flip() +
  facet_wrap(facets = vars(overall_rating_annotated)) +
  labs(title = plot.text
       , caption = caption.text) +
  theme_minimal() +
  theme(panel.grid.major.y = element_blank()
        , panel.grid.minor.x = element_blank()
        , strip.background = element_rect(fill = "#0032a0"
                                          , color = "#0032a0")
        , strip.text = element_text(color = "#fbd022"
                                    , face = "bold")) +
  ggsave(filename = here("visuals", "overall_rating_school_diversity.png")
         , width = 17.2
         , height = 8.84
         , units = "in")

# end of script #
