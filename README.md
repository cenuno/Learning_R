# Learning_R

A repository that teaches R to my fellow Urban Lab colleagues.

## Repository Structure

| **Folder Name** | **Description** |
| :-------------: | :-------------: |
| [`src`](src/)             | This is where all `.R` scripts will be held that are covered in class are stored. |
| [`resources`](resources/)        | This folder will store resources to help expose folks to the material though a variety of slide decks, blog posts, and other relevant examples. |
| [`raw_data`](raw_data/) | This is where all raw data will be stored. |
| [`write_data`](write_data/) | This is were all manipulated data will be stored. |
| [`visuals`](visuals/) | All visuals created will be stored here. |

## Installing R, Rstudio and Tex

Based on your machine, click on the following links to install the necessary software to follow this tutorial:

* [Mac](https://www.reed.edu/data-at-reed/software/R/r_studio.html)
* [PC](https://www.reed.edu/data-at-reed/software/R/r_studio_pc.html)

## Necessary Packages & Session Info
The R scripts were created using R version 3.5.0 and the desktop version of RStudio 1.1.442.

To ensure you can follow along, please install the following packages:

```R
# install necessary packages
install.packages(pkgs = c("broom", "formattable", "here"
                          , "openxlsx", "RCurl", "rgdal"
                          , "tidyverse"))

# end of script #
```

