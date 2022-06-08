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

data_files = "data_files/SIPP/rawdata/"

# LIBRARY
library(tidyverse)
library(haven)
library(lubridate)

options(scipen = 999) # disable scientific notation

# Load data -----

df_sipp_96 <- read_dta(paste0(data_files,"sipp96/sipp96_append.dta"))
df_sipp_01 <- read_dta(paste0(data_files,"sipp01/sipp01_append.dta"))
df_sipp_04 <- read_dta(paste0(data_files,"sipp04/sipp04_append.dta"))
df_sipp_08 <- read_dta(paste0(data_files,"sipp08/sipp08_append.dta"))
df_sipp_14 <- read_dta(paste0(data_files,"sipp14/sipp14_append.dta"))
df_sipp_18 <- read_dta(paste0(data_files,"sipp18/sipp18_append.dta"))

# Clean data -----

df_sipp_96$panel <- c(1996)
df_sipp_01$panel <- c(2001)
df_sipp_04$panel <- c(2004)
df_sipp_08$panel <- c(2008)
df_sipp_14$panel <- c(2014)
df_sipp_18$panel <- c(2018)

df_sipp_14$state <- as.numeric(as.character(df_sipp_14$state))
df_sipp_18$state <- as.numeric(as.character(df_sipp_18$state))

# Append data -----

df_sipp <- bind_rows(df_sipp_96,df_sipp_01,df_sipp_04,df_sipp_08,df_sipp_14,df_sipp_18)

# Clean data -----

df_sipp <- df_sipp %>%
        select(-matches("lgt"), -"_merge",-"ssuid",-"epppnum",-"srefmon")

df_sipp <- zap_labels(df_sipp)

df_sipp <- df_sipp %>%
        filter(weight>0) %>%
        filter(emp==0 | emp == 1) %>%
        filter(age>=25 & age<=54)

df_sipp <- zap_labels(df_sipp)
df_sipp <- zap_label(df_sipp)

# Date ----

df_sipp <- df_sipp %>%
        mutate(date = ifelse(panel == 1996 & wave == 1, yes = "1996-7",
                             ifelse(panel == 1996 & wave == 2, yes = "1996-11",
                                    ifelse(panel == 1996 & wave == 3, yes = "1997-3",
                                           ifelse(panel == 1996 & wave == 4, yes = "1997-7",
                                                  ifelse(panel == 1996 & wave == 5, yes = "1997-11",
                                                         ifelse(panel == 1996 & wave == 6, yes = "1998-3",
                                                                ifelse(panel == 1996 & wave == 7, yes = "1998-7",
                                                                       ifelse(panel == 1996 & wave == 8, yes = "1998-11",
                                                                              ifelse(panel == 1996 & wave == 9, yes = "1999-3",
                                                                                     ifelse(panel == 1996 & wave == 10, yes = "1999-7",
                                                                                            ifelse(panel == 1996 & wave == 11, yes = "1999-11",
                                                                                                   ifelse(panel == 1996 & wave == 12, yes = "2000-3", no = NA)))))))))))))

df_sipp <- df_sipp %>%
        mutate(date = ifelse(panel == 2001 & wave == 1, yes = "2001-5",
                             ifelse(panel == 2001 & wave == 2, yes = "2001-9",
                                    ifelse(panel == 2001 & wave == 3, yes = "2002-1",
                                           ifelse(panel == 2001 & wave == 4, yes = "2002-5",
                                                  ifelse(panel == 2001 & wave == 5, yes = "2002-9",
                                                         ifelse(panel == 2001 & wave == 6, yes = "2003-1",
                                                                ifelse(panel == 2001 & wave == 7, yes = "2003-5",
                                                                       ifelse(panel == 2001 & wave == 8, yes = "2003-9",
                                                                              ifelse(panel == 2001 & wave == 9, yes = "2004-1", no = date))))))))))

df_sipp <- df_sipp %>%
        mutate(date = ifelse(panel == 2004 & wave == 1, yes = "2004-5",
                             ifelse(panel == 2004 & wave == 2, yes = "2004-9",
                                    ifelse(panel == 2004 & wave == 3, yes = "2005-1",
                                           ifelse(panel == 2004 & wave == 4, yes = "2005-5",
                                                  ifelse(panel == 2004 & wave == 5, yes = "2005-9",
                                                         ifelse(panel == 2004 & wave == 6, yes = "2006-1",
                                                                ifelse(panel == 2004 & wave == 7, yes = "2006-5",
                                                                       ifelse(panel == 2004 & wave == 8, yes = "2006-9",
                                                                              ifelse(panel == 2004 & wave == 9, yes = "2007-1",
                                                                                     ifelse(panel == 2004 & wave == 10, yes = "2007-5",
                                                                                            ifelse(panel == 2004 & wave == 11, yes = "2007-9",
                                                                                                   ifelse(panel == 2004 & wave == 12, yes = "2008-1", no = date)))))))))))))

df_sipp <- df_sipp %>%
        mutate(date = ifelse(panel == 2008 & wave == 1, yes = "2008-12",
                             ifelse(panel == 2008 & wave == 2, yes = "2009-4",
                                    ifelse(panel == 2008 & wave == 3, yes = "2009-8",
                                           ifelse(panel == 2008 & wave == 4, yes = "2009-12",
                                                  ifelse(panel == 2008 & wave == 5, yes = "2010-4",
                                                         ifelse(panel == 2008 & wave == 6, yes = "2010-8",
                                                                ifelse(panel == 2008 & wave == 7, yes = "2010-12",
                                                                       ifelse(panel == 2008 & wave == 8, yes = "2011-4",
                                                                              ifelse(panel == 2008 & wave == 9, yes = "2011-8",
                                                                                     ifelse(panel == 2008 & wave == 10, yes = "2011-12",
                                                                                            ifelse(panel == 2008 & wave == 11, yes = "2012-4",
                                                                                                   ifelse(panel == 2008 & wave == 12, yes = "2012-8", 
                                                                                                          ifelse(panel == 2008 & wave == 13, yes = "2012-12",
                                                                                                                 ifelse(panel == 2008 & wave == 14, yes = "2013-4",
                                                                                                                        ifelse(panel == 2008 & wave == 15, yes = "2013-8",
                                                                                                                               ifelse(panel == 2008 & wave == 16, yes = "2013-12", no = date)))))))))))))))))

df_sipp <- df_sipp %>%
        mutate(date = ifelse(panel == 2014 & wave == 1, yes = "2013-4",
                             ifelse(panel == 2014 & wave == 2, yes = "2013-8",
                                    ifelse(panel == 2014 & wave == 3, yes = "2013-12",
                                           ifelse(panel == 2014 & wave == 4, yes = "2014-4",
                                                  ifelse(panel == 2014 & wave == 5, yes = "2014-8",
                                                         ifelse(panel == 2014 & wave == 6, yes = "2014-12",
                                                                ifelse(panel == 2014 & wave == 7, yes = "2015-4",
                                                                       ifelse(panel == 2014 & wave == 8, yes = "2015-8",
                                                                              ifelse(panel == 2014 & wave == 9, yes = "2015-12",
                                                                                     ifelse(panel == 2014 & wave == 10, yes = "2016-4",
                                                                                            ifelse(panel == 2014 & wave == 11, yes = "2016-8",
                                                                                                   ifelse(panel == 2014 & wave == 12, yes = "2016-12", no = date)))))))))))))

df_sipp <- df_sipp %>%
        mutate(date = ifelse(panel == 2018 & wave == 1, yes = "2018-4",
                             ifelse(panel == 2018 & wave == 2, yes = "2018-8",
                                    ifelse(panel == 2018 & wave == 3, yes = "2018-12",
                                           ifelse(panel == 2018 & wave == 4, yes = "2019-4",
                                                  ifelse(panel == 2018 & wave == 5, yes = "2019-8",
                                                         ifelse(panel == 2018 & wave == 6, yes = "2019-12",
                                                                ifelse(panel == 2018 & wave == 7, yes = "2020-4",
                                                                       ifelse(panel == 2018 & wave == 8, yes = "2020-8",
                                                                              ifelse(panel == 2018 & wave == 9, yes = "2020-12", no = date))))))))))

df_sipp$date <- ym(df_sipp$date)

# Save data -----

write_rds(df_sipp, paste0(data_files,"sipp.rds"))

