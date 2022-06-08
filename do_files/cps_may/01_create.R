# TOP COMMANDS -----
# https://www.understandingsociety.ac.uk/documentation/mainstage/dataset-documentation/index/
# https://stackoverflow.com/questions/7505547/detach-all-packages-while-working-in-r
detachAllPackages <- function() {
        basic.packages <- c("package:stats","package:graphics","package:grDevices","package:utils","package:datasets","package:methods","package:base")
        package.list <- search()[ifelse(unlist(gregexpr("package:",search()))==1,TRUE,FALSE)]
        package.list <- setdiff(package.list,basic.packages)
        if (length(package.list)>0)  for (package in package.list) detach(package, character.only=TRUE)
        
}
detachAllPackages()
rm(list=ls(all=TRUE))

# FOLDERS
setwd("~/GitHub/usa_trends_contingent_work/")

data_files = "data_files/cps_may/"

# LIBRARY
library(tidyverse)
library(haven)

options(scipen = 999) # disable scientific notation

# Load data -----

df_cps <- read_dta(paste0(data_files,"cps_00006.dta"))

# Clean data -----

df_cps <- zap_labels(df_cps)
df_cps <- zap_label(df_cps)
df_cps <- zap_formats(df_cps)

df_cps <- df_cps %>%
        filter(cwsuppwt > 0)

# Save data -----

write_rds(df_cps, paste0(data_files,"cps_may_cws.rds"))

