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
graphs = "graphs/"

# LIBRARY
library(tidyverse)
library(Hmisc)

options(scipen = 999) # disable scientific notation

# Load data -----

df_cps <- readRDS(paste0(data_files,"cps_may_cws.rds"))

# Clean data -----

df_cps <- df_cps %>%
        filter(age>=25 & age <=54) %>%
        filter(empstat == 10 | empstat == 12)


# Summarise data -----

df_contingent <- df_cps %>%
        filter(cwdefbrd<90) %>%
        mutate(cwdefbrd = cwdefbrd - 1) %>%
        group_by(year) %>%
        summarise(mean = wtd.mean(cwdefbrd, weights = cwsuppwt)) %>%
        ungroup() %>%
        mutate(variable = "Contingent")

df_contingent

df_agency <- df_cps %>%
        filter(cwtytemp<90) %>%
        mutate(cwtytemp = cwtytemp - 1) %>%
        group_by(year) %>%
        summarise(mean = wtd.mean(cwtytemp, weights = cwsuppwt)) %>%
        ungroup() %>%
        mutate(variable = "Temp agency")

df_agency

df_oncall <- df_cps %>%
        filter(cwtycoctr<90) %>%
        mutate(cwtycoctr = cwtycoctr - 1) %>%
        group_by(year) %>%
        summarise(mean = wtd.mean(cwtycoctr, weights = cwsuppwt)) %>%
        ungroup() %>%
        mutate(variable = "On call")

df_contract <- df_cps %>%
        filter(cwtycoctr<90) %>%
        mutate(cwtycoctr = cwtycoctr - 1) %>%
        group_by(year) %>%
        summarise(mean = wtd.mean(cwtycoctr, weights = cwsuppwt)) %>%
        ungroup() %>%
        mutate(variable = "Contract firms")

df_independent


df_independent <- df_cps %>%
        filter(cwtyinctr<90) %>%
        mutate(cwtyinctr = cwtyinctr - 1) %>%
        group_by(year) %>%
        summarise(mean = wtd.mean(cwtyinctr, weights = cwsuppwt)) %>%
        ungroup() %>%
        mutate(variable = "Independent contractor")
df_independent

# Graph data -----

df_graph <- rbind(df_contingent,df_agency,df_oncall,df_contract,df_independent)

df_graph$variable <- factor(df_graph$variable, 
                            levels = c("Contingent", "Contract firms","Temp agency","On call","Independent contractor"))

df_graph$mean <- df_graph$mean*100

ggplot(data=df_graph, aes(x=variable, y=mean, fill = as.factor(year))) +
        geom_bar(stat="identity", position=position_dodge()) +
        scale_y_continuous(limits = c(0,8), breaks = seq(0,8,2)) +
        scale_fill_grey(start = .8, end = .2) +
        theme_bw() +
        ylab("Rate of contingent work") +
        theme(panel.grid.minor = element_blank(), 
              legend.title=element_blank(),
              axis.title.x=element_blank(),
              legend.key.width = unit(2,"cm"),
              legend.position = "bottom",
              axis.line.y = element_line(color="black", size=.5),
              axis.line.x = element_line(color="black", size=.5)
        ) +
        geom_text(data = df_graph,
                  position=position_dodge(width=0.9), 
                  size = 3, 
                  aes(x = variable, y = ifelse(year %in% c(1995,2001,2017), yes = mean, no = NA),
                      vjust=-2,
                      label=sprintf(mean, fmt = '%#.2f')))

ggsave(plot = last_plot(), filename = paste0(graphs,"graph_cps_rate.pdf"), height = 6, width = 9, units = "in")


