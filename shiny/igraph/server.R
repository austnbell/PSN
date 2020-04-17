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

displayImportances <- function(input, output, session, cluster_num){
  # subset and reshape to value
  temp_importances <- reactive({
    # remove other cluster
    temp_importances <- feature_importances %>%
      filter(cluster %in% c(cluster_num(), "Total"))
    
    # reshape 
    temp_importances <- dcast(temp_importances, Feature ~ cluster, value.var = "Value")
    colnames(temp_importances) <- c("Feature", "cluster_value", "total_value")
    
    # compute Ratios
    temp_importances <- temp_importances %>%
      mutate(cluster_value = cluster_value / sum(temp_importances$cluster_value, na.rm = TRUE),
             total_value = total_value / sum(temp_importances$total_value, na.rm = TRUE)) %>%
      arrange(desc(cluster_value))
    
    temp_importances$Feature <- factor(temp_importances$Feature, levels = as.vector(temp_importances$Feature))
    
    # subset
    temp_importances <- temp_importances[0:25,]
  })
  
  fig <- reactive({
    fig <- plot_ly(temp_importances(), x = ~Feature, y = ~cluster_value, type = 'bar', 
                   name = 'Cluster Importances', marker = list(color = 'rgb(49,130,189)'))
    fig <- fig %>% add_trace(y = ~total_value, name = 'Total Importances', marker = list(color = 'rgb(204,204,204)'))
    fig <- fig %>% layout(xaxis = list(title = "", tickangle = -45),
                          yaxis = list(title = ""),
                          barmode = 'group')
    fig
  })
  
  
  return(fig())
  
}





# Define server logic required to draw a histogram
server <- function(input, output, session) {
   

  # Networks ----------------------------------------------------------------
  # the graph
  output$sim_network <- renderPlot({
    print(input$select_subgroup)
    callModule(displayNetworks, "disp_net", reactive(input$select_subgroup))
    
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
  

  # Prediction Analysis -----------------------------------------------------
  # Summary Table 
  output$`30day_summary` <- renderDT({
    callModule(predSummary, "preds_sum")
  })
  
  # feature importances
  output$`30day_features` <- renderPlotly({
    x <- input$select_cluster
    callModule(displayImportances, "feats_imp", reactive(input$select_cluster))
  })
  
  
}
