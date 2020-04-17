#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
source("./serverNetworks.R")
source("./serverPredictions.R")
source("./statTests.R")


# normalize 
minMaxNormalize <- function(column){
  min <- min(column, na.rm = T)
  max <- max(column, na.rm = T)
  new_col <- (column - min)/(max - min)
  return(new_col)
}


# Define server logic required to draw a histogram
server <- function(input, output, session) {
   

  # Networks ----------------------------------------------------------------
  # select graph
  g <- reactive({graph_list[[input$select_subgroup]] })
  
  
  # the graph
  output$sim_network <- renderVisNetwork({
    input$select_subgroup
    #callModule(displayNetworks, "disp_net", reactive(input$select_subgroup))
    callModule(displayVis, "disp_net", g())
    
  })
  
  # Identify the selected nodes 
  selected_nodes <- reactive({
    req(input$current_node_id)
    names(ego(g(), order = 2, nodes = input$current_node_id)[[1]])
  })
  
  
  # differentiators
  output$numeric_diff <- renderDT({
    x <- c(input$select_cluster, input$select_subgroup)
    callModule(numericDifferences, "num_diff", 
               reactive(input$select_cluster), 
               reactive(input$select_subgroup))
  })
  
  output$categorical_diff <- renderDT({
    x <- c(input$select_cluster, input$select_subgroup)
    callModule(catDifferences, "cat_diff", 
               reactive(input$select_cluster), 
               reactive(input$select_subgroup))
  })
  
  # interactive differences
  stats_res <- reactive({
    req(input$current_node_id)
    
    # extract data
    sample_pts <- genSampleDFs(patient_df, reactive(input$select_subgroup), selected_nodes(), g())
    selected_pts <- sample_pts[[1]]
    comparison_pts <- sample_pts[[2]]
    
    # run satistical tests
    num_results <- tTests(selected_pts, comparison_pts)
    cat_results <- chi2Tests(selected_pts, comparison_pts)
    
    return(list(num_results, cat_results))
  })
  
  output$int_num_diff <- renderDT({
    req(input$current_node_id)
    num_results <- stats_res()[[1]]
    callModule(interactNumDiffs, "num_diff_int", num_results)
  })
  
  output$cat_num_diff <- renderDT({
    req(input$current_node_id)
    cat_results <- stats_res()[[2]]
    callModule(interactCatDiffs, "cat_diff_int", cat_results)

  })
  

  # Prediction Analysis -----------------------------------------------------
  # Summary Table 
  output$`30day_summary` <- renderDT({
    callModule(predSummary, "preds_sum")
  })
  output$mortality_summary <- renderTable({
    event_stats_out <- event_stats
    
    # if we have selected nodes then we display the mortality statistics for those patients 
    if(!(is.null(input$current_node_id))){
      selected_df <- patient_df %>%
        filter(subject_id %in% selected_nodes())
      
      event_stats_out <- event_stats_out %>%
        add_row(cluster = "Selected Nodes",
                `Mortality within 30 Days Ratio` = mean(selected_df$mortality30, na.rm = T),
                `Avg. Num. Days to Death` = mean(selected_df$time2event, na.rm = T))
    }
    
    
    event_stats_out
  })
  
  # feature importances
  output$`30day_features` <- renderPlotly({
    input$select_cluster
  
    importances  <- callModule(getImportances, "feats_imp", reactive(input$select_cluster))
    
    if(!(is.null(input$current_node_id))){
      shap_nodes <- shapPipeline$computeMeanShap(patient_df %>% select(-special_diet, -appetite), selected_nodes())
      names(shap_nodes)[names(shap_nodes) == "importance"] <- "nodes_value"
      importances <- merge(importances, shap_nodes, by = "feature")
      print(shap_nodes)
    }
    
    # normalize columns - to make them 
    for(col in colnames(importances)[2:ncol(importances)]){
      importances[[col]] <- minMaxNormalize(importances[[col]])
    }
    
    # plot the grouped barchart
    fig <- plot_ly(importances, x = ~feature, y = ~cluster_value, type = 'bar', 
                   name = 'Cluster Importances', marker = list(color = 'rgb(49,130,189)'))
    fig <- fig %>% add_trace(y = ~total_value, name = 'Total Importances', marker = list(color = 'rgb(204,204,204)'))
    if(!(is.null(input$current_node_id))){
      fig <- fig %>% add_trace(y = ~nodes_value, name = 'Selected Nodes Importances', marker = list(color = 'darkred'))
    }
    
    fig <- fig %>% layout(xaxis = list(title = "", tickangle = -45),
                          yaxis = list(title = ""),
                          barmode = 'group')
    
    
    
    
    
    
  })
  
  
}

