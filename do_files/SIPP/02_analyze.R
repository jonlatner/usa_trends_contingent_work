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
graphs = "graphs/"

# LIBRARY
library(tidyverse)
library(Hmisc)

options(scipen = 999) # disable scientific notation

# Load data -----

df_sipp <- readRDS(paste0(data_files,"sipp.rds"))

table(df_sipp$panel)

# Clean data -----

df_sipp <- df_sipp %>%
        select(-matches("lg")) %>%
        select(id, panel, wave, date, matches("emp"), matches("contingent"), matches("temp_agency"), weight) %>%
        arrange(panel, id, wave)

df_sipp <- df_sipp %>%
        filter(wave < 10) %>%
        group_by(id,panel) %>%
        mutate(count = row_number(),
               max = max(count)
               ) %>%
        ungroup() %>%
        filter(max == 9) %>%
        select(-count,-max)

with(df_sipp,table(df_sipp$contingent_1,emp_type_1))

df_sipp <- df_sipp %>%
        mutate(temp_work = ifelse(contingent == 1 | contingent_1 == 1 | temp_agency == 1, yes = 1, no = NA),
               temp_work = ifelse(is.na(temp_work), yes = 0, no = temp_work),
               contingent_work = ifelse(contingent == 1 | contingent_1 == 1, yes = 1, no = NA),
               contingent_work = ifelse(is.na(contingent_work), yes = 0, no = contingent_work),
               agency_work = ifelse(temp_agency == 1, yes = 1, no = NA),
               agency_work = ifelse(is.na(agency_work), yes = 0, no = agency_work),
        )

with(df_sipp,table(panel,contingent,useNA = "ifany"))

df_sipp <- df_sipp %>%
        group_by(id, panel) %>%
        mutate(temp_work_num = cumsum(temp_work),
               temp_work_num = max(temp_work_num),
               temp_work_ever = ifelse(temp_work_num>0, yes = 1, no = 0),
               contingent_work_num = cumsum(contingent_work),
               contingent_work_num = max(contingent_work_num),
               contingent_work_ever = ifelse(contingent_work_num>0, yes = 1, no = 0),
               agency_work_num = cumsum(agency_work),
               agency_work_num = max(agency_work_num),
               agency_work_ever = ifelse(agency_work_num>0, yes = 1, no = 0),
        ) %>%
        ungroup()

# Graph data avg. number -----

df_graph_num_avg <- df_sipp %>%
        filter(emp == 1,
               temp_work_ever > 0) %>%
        mutate(panel = as.factor(panel)) %>%
        group_by(panel) %>%
        summarise(temp_work_num = wtd.mean(temp_work_num, weights = weight),
                  # contingent_work_num = wtd.mean(contingent_work_num, weights = weight),
                  # agency_work_num = wtd.mean(agency_work_num, weights = weight),
                  ) %>%
        ungroup()

df_graph_num_avg <- pivot_longer(df_graph_num_avg, !panel)
df_graph_num_avg

df_graph_num_avg$name <- factor(df_graph_num_avg$name, 
                                levels = c("temp_work_num","agency_work_num","contingent_work_num"),
                                labels = c("Temporary work", "Temp agency work", "Contingent work"))

ggplot(data=df_graph_num_avg, aes(x=panel, y=value)) +
        geom_bar(stat="identity", position=position_dodge()) +
        scale_y_continuous(limits = c(0,5)) +
        theme_bw() +
        ylab("Conditional on 1, average number of waves with contingent work") +
        theme(panel.grid.minor = element_blank(), 
              legend.title=element_blank(),
              axis.title.x=element_blank(),
              legend.key.width = unit(2,"cm"),
              legend.position = "bottom",
              axis.line.y = element_line(color="black", size=.5),
              axis.line.x = element_line(color="black", size=.5)
        ) +
        geom_text(data = df_graph_num_avg,
                  position=position_dodge(width=0.9),
                  size = 3, 
                  aes(x = panel, y = value, vjust=-2, 
                      label=sprintf(value, fmt = '%#.2f')))

ggsave(filename = paste0(graphs,"graph_sipp_number_avg.pdf"), plot = last_plot(), height = 6, width = 9, units = "in")

# Graph data avg. number -----

df_graph_num_2 <- df_sipp %>%
        filter(emp == 1,
               temp_work_ever > 0) %>%
        mutate(panel = as.factor(panel),
               temp_work_num = ifelse(temp_work_num == 2, yes = 1, no = 0),
               # contingent_work_num = ifelse(contingent_work_num == 2, yes = 1, no = 0),
               # agency_work_num = ifelse(agency_work_num == 2, yes = 1, no = 0),
        ) %>%
        group_by(panel) %>%
        summarise(temp_work_num = wtd.mean(temp_work_num, weights = weight),
                  # contingent_work_num = wtd.mean(contingent_work_num, weights = weight),
                  # agency_work_num = wtd.mean(agency_work_num, weights = weight),
        ) %>%
        ungroup() %>%
        mutate(label = "2")

df_graph_num_3 <- df_sipp %>%
        filter(emp == 1,
               temp_work_ever > 0) %>%
        mutate(panel = as.factor(panel),
               temp_work_num = ifelse(temp_work_num == 3, yes = 1, no = 0),
               # contingent_work_num = ifelse(contingent_work_num == 3, yes = 1, no = 0),
               # agency_work_num = ifelse(agency_work_num == 3, yes = 1, no = 0),
        ) %>%
        group_by(panel) %>%
        summarise(temp_work_num = wtd.mean(temp_work_num, weights = weight),
                  # contingent_work_num = wtd.mean(contingent_work_num, weights = weight),
                  # agency_work_num = wtd.mean(agency_work_num, weights = weight),
        ) %>%
        ungroup() %>%
        mutate(label = "3")


df_graph_num_4 <- df_sipp %>%
        filter(emp == 1,
               temp_work_ever > 0) %>%
        mutate(panel = as.factor(panel),
               temp_work_num = ifelse(temp_work_num >= 4, yes = 1, no = 0),
               # contingent_work_num = ifelse(contingent_work_num >= 4, yes = 1, no = 0),
               # agency_work_num = ifelse(agency_work_num >= 4, yes = 1, no = 0),
        ) %>%
        group_by(panel) %>%
        summarise(temp_work_num = wtd.mean(temp_work_num, weights = weight),
                  # contingent_work_num = wtd.mean(contingent_work_num, weights = weight),
                  # agency_work_num = wtd.mean(agency_work_num, weights = weight),
        ) %>%
        ungroup() %>%
        mutate(label = ">= 4")


df_graph_num_all <- df_sipp %>%
        filter(emp == 1,
               temp_work_ever > 0) %>%
        mutate(panel = as.factor(panel),
               temp_work_num = ifelse(temp_work_num == 9, yes = 1, no = 0),
               # contingent_work_num = ifelse(contingent_work_num >= 4, yes = 1, no = 0),
               # agency_work_num = ifelse(agency_work_num >= 4, yes = 1, no = 0),
        ) %>%
        group_by(panel) %>%
        summarise(temp_work_num = wtd.mean(temp_work_num, weights = weight),
                  # contingent_work_num = wtd.mean(contingent_work_num, weights = weight),
                  # agency_work_num = wtd.mean(agency_work_num, weights = weight),
        ) %>%
        ungroup() %>%
        mutate(label = "All")

df_graph_num_2
df_graph_num_3
df_graph_num_4
df_graph_num_all

df_graph_num <- rbind(df_graph_num_2,df_graph_num_3,df_graph_num_4,df_graph_num_all)
table(df_graph_num$label)

df_graph_num$label <- factor(df_graph_num$label, 
                            levels = c("2","3",">= 4", "All"),
                            labels = c("2","3",">= 4", "All 9 waves"))

table(df_graph_num$label)

ggplot(data=df_graph_num, aes(x=label, y=temp_work_num, fill = panel)) +
        geom_bar(stat="identity", position=position_dodge()) +
        scale_y_continuous(limits = c(0,.6), breaks = seq(0,.6,.2)) +
        scale_fill_grey(start = .8, end = .2) +
        theme_bw() +
        xlab("Number of contracts in a 3-year panel period") +
        ylab("Percent distribution of contracts, conditional on one") +
        theme(panel.grid.minor = element_blank(), 
              legend.title=element_blank(),
              # axis.title.x=element_blank(),
              legend.key.width = unit(2,"cm"),
              legend.position = "bottom",
              axis.line.y = element_line(color="black", size=.5),
              axis.line.x = element_line(color="black", size=.5)
        ) +
        geom_text(data = df_graph_num,
                  position=position_dodge(width=0.9), 
                  size = 3, 
                  aes(x = label, y = temp_work_num,
                      vjust=-2,
                      label=sprintf(temp_work_num, fmt = '%#.2f')))

ggsave(filename = paste0(graphs,"graph_sipp_number_distribution.pdf"), plot = last_plot(), height = 6, width = 9, units = "in")


# Graph data rate -----

df_graph_rate <- df_sipp %>%
        filter(emp == 1) %>%
        mutate(panel = as.factor(panel)) %>%
        group_by(panel,date) %>%
        summarise(mean = wtd.mean(temp_work, weights = weight)*100) %>%
        group_by(panel) %>%
        mutate(label = ifelse(row_number()==1 | row_number()==n(), yes = 1, no = 0)) %>%
        ungroup()
df_graph_rate

ggplot(df_graph_rate, aes(x = date, y = mean, group = panel, color = panel)) +
        geom_line() +
        scale_y_continuous(limits=c(0,5)) +
        scale_x_date(date_labels="%m-%Y", breaks = "12 month") +
        ylab("Rate of contingent work") +
        scale_color_grey(start = .6, end = .1) +
        geom_point(size=2) +
        theme_bw() +
        theme(panel.grid.minor = element_blank(),
              # legend.title=element_blank(),
              axis.title.x=element_blank(),
              axis.text.x = element_text(angle = 90),
              legend.key.width = unit(2,"cm"),
              legend.position = "bottom",
              axis.line.y = element_line(color="black", size=.5),
              axis.line.x = element_line(color="black", size=.5)
        ) +
        geom_text(data = df_graph_rate,
                  size = 3,
                  aes(x = date, y = ifelse(label == 1, yes = mean, no = NA),
                      vjust=-1,
                      label=sprintf(mean, fmt = '%#.2f')))

ggsave(filename = paste0(graphs,"graph_sipp_rate.pdf"), plot = last_plot(), height = 6, width = 9, units = "in")

# Graph data risk -----

df_graph_risk <- df_sipp %>%
        filter(emp == 1) %>%
        mutate(panel = as.factor(panel)) %>%
        group_by(panel) %>%
        summarise(mean = wtd.mean(temp_work_ever, weights = weight)*100) %>%
        ungroup()

df_graph_risk

ggplot(data=df_graph_risk, aes(x=panel, y=mean)) +
        geom_bar(stat="identity", position=position_dodge()) +
        scale_y_continuous(limits = c(0,20), breaks = seq(0,20,5)) +
        scale_fill_grey(start = .8, end = .2) +
        theme_bw() +
        ylab("Percent who experience contingent work in a 3-year panel period") +
        theme(panel.grid.minor = element_blank(),
              legend.title=element_blank(),
              axis.title.x=element_blank(),
              legend.key.width = unit(2,"cm"),
              legend.position = "bottom",
              axis.line.y = element_line(color="black", size=.5),
              axis.line.x = element_line(color="black", size=.5)
        ) +
        geom_text(data = df_graph_risk,
                  position=position_dodge(width=0.9),
                  size = 3,
                  aes(x = panel, y = mean,
                      vjust=-2,
                      label=sprintf(mean, fmt = '%#.2f')))

ggsave(filename = paste0(graphs,"graph_sipp_risk.pdf"), plot = last_plot(), height = 6, width = 9, units = "in")

# Save data -----

# write_rds(df_sipp, paste0(data_files,"sipp_sample.rds"))

