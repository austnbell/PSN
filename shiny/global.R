# Global file for the shiny application 
# hard-coded data files to be used across application

###### Libraries
library(tidyverse)
library(igraph) # interactive networks
library(data.table) 
library(hash) # dictionary
library(visNetwork) # work with the graph 
library(DT)
library(shiny)
library(shinydashboard)
library(viridis)   
library(reshape2) 
library(plotly)
library(reticulate)
shapPipeline <- import("shapPipeline") # python functions



###### Paths 
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
#root_dir = "../data"
root_dir = "./data"
graph_dir = paste(root_dir, "graphs/sampledGraphs", sep = "/")
heor_dir = paste(root_dir, "heorData/results", sep = "/")

# graph seed
set.seed(42)

# Full patient dataframe
patient_df = read.csv(paste(root_dir, "Patient Level Dataset.csv", sep = "/"), stringsAsFactors = F)

# Cluster Analysis --------------------------------------------------------
# cluster dataframe
cluster_df <- read.csv(paste(root_dir, "/graphs/cosine_cluster5.csv", sep = "/"),
                      stringsAsFactors = F)
clusters <- unique(cluster_df$cluster)


# data subgroup dictionary
subgroupMapping <- read.csv(paste(root_dir, "subgroupMapping.csv", sep = "/"),
                           stringsAsFactors = F) %>%
  mutate(column = str_replace_all(column, "-", "\\.")) %>%
  group_by(subgroup) %>%
  summarise(columns = strsplit(paste(column, collapse = "-"), "-")) %>%
  filter(!(subgroup %in% c("mortality", "procedures")))

subgroups <- c("all", as.character(subgroupMapping$subgroup)) # keys 
subgroupMapping <- hash::hash(keys = subgroupMapping$subgroup, values = subgroupMapping$columns) # dict
#subgroupMapping[['pain level']]

# import cluster comparison - this will need to be reformatted, but wait until I get there
numeric_report <-read.csv(paste(heor_dir, "Numeric Report Cleaned (cosine_knn5_k2).csv", sep = "/"),
                          stringsAsFactors = F)
cat_report <-read.csv(paste(heor_dir, "Categorical Report Cleaned (cosine_knn5_k2).csv", sep = "/"),
                          stringsAsFactors = F)

# import and generate the graphs 
graph_files <- list.files(graph_dir)
graph_files <- graph_files[grep("\\.csv", graph_files)]
graph_list <- list()

for(sg in subgroups){
  print(sg)
  v = read.csv(paste0(graph_dir, "/", sg, " vertices sampled.csv"))
  e = read.csv(paste0(graph_dir, "/", sg, " edges sampled.csv"))
  
  cluster_tmp = cluster_df[cluster_df$subject_id %in% v$subject_id,]
  v = merge(v, cluster_tmp, by = "subject_id")
  
  # generate the graph with clusters
  g <- graph_from_data_frame(e, directed=TRUE, vertices=v)
  V(g)$color <- v$cluster
  g <- set_graph_attr(g, "layout", layout_with_fr(g))
  
  graph_list[[sg]] <- g
}





# Predictive Analysis -----------------------------------------------------

summary_30day <- read.csv(paste(heor_dir, "Summary Table.csv", sep = "/"),
                          stringsAsFactors = F)

feature_importances <- read.csv(paste(heor_dir, "Feature Importances.csv", sep = "/"),
                                stringsAsFactors = F)

# get event statistics by group
event_stats <- patient_df %>%
  select(cluster, mortality30, time2event)%>%
  group_by(cluster) %>%
  summarise(`Mortality within 30 Days Ratio` = round(mean(mortality30),3),
            `Avg. Num. Days to Death` = round(mean(time2event, na.rm = TRUE),2)) %>%
  add_row(cluster = "Total", 
          `Mortality within 30 Days Ratio` = round(mean(patient_df$mortality30),3),
          `Avg. Num. Days to Death` = round(mean(patient_df$time2event, na.rm = TRUE),2)) 



