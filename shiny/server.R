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
source("./serverSurvival.R")

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
    
    # bootstrap to get accurate statistical estimates 
    num_results <- list()
    cat_results <- list()
    
    for(i in 1:50){
      # extract data
      sample_pts <- genSampleDFs(patient_df, reactive(input$select_subgroup), selected_nodes(), g())
      selected_pts <- sample_pts[[1]]
      comparison_pts <- sample_pts[[2]]
      
      # run satistical tests
      num_results[[i]] <- tTests(selected_pts, comparison_pts)
      cat_results[[i]] <- chi2Tests(selected_pts, comparison_pts)
    }
    
    # average our t-ttests
    num_results <- bind_rows(num_results) %>% 
      group_by(variable) %>%
      summarize(cluster_mean = mean(cluster_mean, na.rm = T),
                other_mean = mean(other_mean, na.rm = T),
                cluster_std = mean(cluster_std, na.rm = T), 
                other_std = mean(other_std, na.rm = T), 
                p_value = mean(p_value, na.rm = T)) %>%
      ungroup()
    
    # average our chisq tests
    cat_results <- bind_rows(cat_results) %>%
      group_by(variable, primary_label, secondary_label) %>%
      summarize(primary_cluster_value = mean(primary_cluster_value, na.rm = T),
                primary_other_value = mean(primary_other_value, na.rm = T),
                secondary_cluster_value = mean(secondary_cluster_value, na.rm = T),
                secondary_other_value = mean(secondary_other_value, na.rm = T),
                p_value = mean(p_value, na.rm = T)) %>%
      ungroup() %>%
      select(variable, primary_label, primary_cluster_value, primary_other_value,
             secondary_label, secondary_cluster_value, secondary_other_value, p_value)
    
    
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
  
  stats_dfs <- reactiveValues(mortality_stat = NULL)
  # Prediction Analysis -----------------------------------------------------
  # Summary Table 
  output$`30day_summary` <- renderDT({
    callModule(predSummary, "preds_sum")
  })
  
  output$mortality_summary <- renderDataTable({
    datatable(event_stats, options = list(dom = 't')) %>%
      formatRound(c(2,3),2)
  })
 
  observeEvent(input$current_node_id, {   
    print(input$current_node_id)
    
    selected_df <- patient_df %>%
      filter(subject_id %in% selected_nodes())
    
    event_stats_out <- event_stats%>%
      add_row(cluster = "Selected Nodes",
              `Mortality within 30 Days Ratio` = mean(selected_df$mortality30, na.rm = T),
              `Avg. Num. Days to Death` = mean(selected_df$time2event, na.rm = T))
    

    proxy1 <- DT::dataTableProxy('mortality_summary')
    DT::replaceData(proxy1, event_stats_out)
    print(event_stats_out)
  
  })
  

  
  # feature importances
  output$`30day_features` <- renderPlotly({
    input$select_cluster
  
    importances  <- callModule(getImportances, "feats_imp", reactive(input$select_cluster))
    
    if(!(is.null(input$current_node_id))){
      shap_nodes <- shapPipeline$computeMeanShap(patient_df %>% select(-special_diet, -appetite), selected_nodes())
      names(shap_nodes)[names(shap_nodes) == "importance"] <- "nodes_value"
      importances <- merge(importances, shap_nodes, by = "feature")
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
  
  # Survival Analysis -------------------------------------------------------
  
  sa_selected <- reactive({
    req(input$current_node_id)
    
    survival$selected_nodes <- ifelse(survival$subject_id %in% selected_nodes(), 1, 0)
    survfit(Surv(time2event, survival) ~ selected_nodes, data = survival)
    
  })
  
  output$survival_summary <- function() {
    smry_cluster <- callModule(survivalTable, "sa_c", sa_cluster, 2, input$num_surv, c("Cluster 0", "Cluster 1"))
    smry_total <- callModule(survivalTable, "sa_t", sa_total, 1, input$num_surv, c("Total"))
    smry <- bind_rows(smry_total, smry_cluster)

    smry %>%
    knitr::kable("html") %>%
      kable_styling("striped", full_width = F)
  }
  
  # summary table
  output$survival_selected <- function(){
    req(input$current_node_id)
    sa_sel <- sa_selected()

    callModule(survivalTable, "sa_s", sa_sel, 2, input$num_surv, c("Other", "Selected Nodes")) %>%
    knitr::kable("html") %>%
      kable_styling("striped", full_width = F)
  }
  
  
  # survival plot 
  output$survival_plot <- renderPlot({
    
    if(!is.null(input$current_node_id)){
      fit <- list("Total"= sa_total, "Selected" = sa_selected())
    } else {
      fit <- list("Total"= sa_total, "Clusters" = sa_cluster)
    }
    
    
    ggsurvplot_combine(
      fit = fit, 
      xlab = "Days", 
      ylab = "Overall survival probability",
      data = survival,
      risk.table = TRUE)
    
  })
  
  # hazard plots and tables
  output$cox_regression <- function(){
    if(!is.null(input$current_node_id)){
      survival$selected_nodes <- ifelse(survival$subject_id %in% selected_nodes(), 1, 0)
      broom::tidy(
        coxph(Surv(time2event, survival) ~ selected_nodes, data = survival), 
        exp = TRUE
      ) %>%
        knitr::kable("html") %>%
        kable_styling("striped", full_width = F)
      
    } else {
      broom::tidy(
        coxph(Surv(time2event, survival) ~ cluster, data = survival), 
        exp = TRUE
      ) %>%
        knitr::kable("html") %>%
        kable_styling("striped", full_width = F)
    }
    
    
  }
  
  
  output$cumhaz_plot <- renderPlot({
    
    
    if(!is.null(input$current_node_id)){
      fit <- list("Selected" = sa_selected())
    } else {
      fit <- list("Clusters" = sa_cluster)
    }
    
    ggsurvplot_combine(
      fit = fit, 
      xlab = "Days", 
      ylab = "Cumulative Hazard Ratio",
      data = survival,
      fun = "cumhaz")
  })
  
}

