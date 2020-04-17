## Server code to display the networks 
library(igraph)
library(visNetwork)
library(tidyverse)


# Display our Network -----------------------------------------------------


displayNetworks <- function(input, output, session, sg){
  
  # select graph
  g <- reactive({
    graph_list[[sg()]]
  })
  
  # plot graph
  pal <- viridis(4)[c(1,3)]
  v_pal = pal[as.factor(V(g())$color)]
  
  plot.igraph(g(), vertex.size = 5, vertex.label = NA, edge.arrow.size = .5, vertex.color=v_pal)
  legend("topleft", legend = unique(V(g())$color), fill = pal, bty = "n", border = NA)
  
}


# Display our Statistical Test Results ------------------------------------

numericDifferences <- function(input, output, session, selected_cluster, selected_subgroup){
  numeric_tmp <- reactive({
    # subset
    
    if(selected_subgroup() != "all") {
      numeric_tmp <- numeric_report  %>% 
        filter(cluster == selected_cluster(), data_subgroup == selected_subgroup()) %>% 
        select(-cluster) %>%
        arrange(p_value) 
      
    } else{
      numeric_tmp <- numeric_report  %>% 
        filter(cluster == selected_cluster()) %>% 
        select(-cluster) %>%
        arrange(p_value)
    }
    
  })
  
  output <- reactive({
    # format
    datatable(numeric_tmp(),
              colnames = c("Variable", "Cluster Mean", "Other Mean", 
                           "Cluster STD", "Other STD", "P Value", "Subgroup"),
              rownames = F
    )
  })
  return(output())
}

catDifferences <- function(input, output, session, selected_cluster, selected_subgroup){
  output <- reactive({
    # subset
    cat_tmp <- cat_report %>% 
      filter(cluster == selected_cluster()) %>%
      select(-cluster) %>%
      arrange(p_value)
    
    print(selected_subgroup())
    if(selected_subgroup() != "all") {
      cat_tmp2 <- cat_tmp %>%
        filter(data_subgroup == selected_subgroup())
    } else{
      cat_tmp2 <- cat_tmp
    }
    
    # format
    datatable(cat_tmp2,
              colnames = c("Variable", "1st Label", "1st Cluster Value", "1st Other Value",
                           "2nd Label", "2nd Cluster Value", "2nd Other Value",
                           "3rd Label", "3rd Cluster Value", "3rd Other Value",
                           "P Value", "Subgroup"),
              rownames = F
    )
  })
  return(output())
}