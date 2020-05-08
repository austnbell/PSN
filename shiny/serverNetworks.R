## Server code to display the networks 
library(igraph)
library(visNetwork)
library(tidyverse)



# Display our Network -----------------------------------------------------


# Interactive
displayVis <- function(input, output, session, g){
  
  # format graph
  vis_data <- toVisNetworkData(g)
  vis_data$nodes$color = c("forestgreen", "steelblue")[as.factor(V(g)$color)]
  vis_data$edges$color <- c("grey")
  
  # legend nodes
  lnodes <- data.frame(label = c("Cluster 0", "Cluster 1"), 
                       color = c("steelblue", "forestgreen"),
                       title = "Legend") 
  
  # plot graph
  visNetwork(nodes = vis_data$nodes, edges = vis_data$edges, height = "500px") %>%
    visPhysics(stabilization = FALSE)  %>%
    visEdges(smooth = FALSE, color = list(highlight = "darkred"))  %>%
    visNodes(color = list(highlight = 'darkred'))%>%
    visOptions(highlightNearest = list(enabled = T, degree = 2, hover = F)) %>%
    visEvents(select = "function(nodes) {
              Shiny.onInputChange('current_node_id', nodes.nodes);
              ;}") %>% 
    visInteraction(dragNodes = FALSE, 
                   dragView = FALSE, 
                   zoomView = TRUE, 
                   selectable = TRUE,
                   multiselect = TRUE) %>%
    visNodes(color = list(highlight = 'darkred'))%>%
    visIgraphLayout(layout = "layout_with_fr", randomSeed =42) %>%
    visLegend( main = "Legend", addNodes = lnodes, useGroups = FALSE, stepY = 50)
  
  
  }


# standard Igraph
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

# display statistical results of selected node 
interactNumDiffs <- function(input, output, session, num_results){
  output <- reactive({
    datatable(num_results %>% 
                arrange(p_value),
              colnames = c("Variable", "Selected Mean", "Other Mean", 
                           "Selected STD", "Other STD", "P Value"),
              rownames = F,
              options = list(pageLength = 3)
    ) %>%
      formatRound(2:ncol(num_results), digits=2)
  })
  
  return(output())
  
}

interactCatDiffs <- function(input, output, session, cat_results){
  output <- reactive({
    datatable(cat_results %>% 
                arrange(p_value),
              colnames = c("Variable", "1st Label", "1st Cluster Value", "1st Other Value",
                           "2nd Label", "2nd Cluster Value", "2nd Other Value",
                           "P Value"),
              rownames = F,
              options = list(pageLength = 3)
    ) %>%
      formatRound(columns = c("primary_cluster_value", "primary_other_value",
                              "secondary_cluster_value", "secondary_other_value", "p_value"), digits=2)
  })
  return(output())
  
}
