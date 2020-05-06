## Server code to display the 30 day mortality prediction results
library(tidyverse)


# Summary -----------------------------------------------------------------


predSummary <- function(input, output, session){
  return(datatable(summary_30day,
                   rownames = F,
                   colnames = c("Group / Cluster", "Num. Pts (Train)", "Num. Pts (Val)",
                                "Precision", "Recall", "AUC Score", "F1 Score"), 
                   options = list(dom = 't')) %>%
           formatRound(c(4,5,6,7),2))
}


# Feature Importances -----------------------------------------------------

# normalize 
minMaxNormalize <- function(column){
  min <- min(column, na.rm = T)
  max <- max(column, na.rm = T)
  new_col <- (column - min)/(max - min)
  return(new_col)
}


getImportances <- function(input, output, session, cluster_num){
  # subset and reshape to value
  temp_importances <- reactive({
    # remove other cluster
    temp_importances <- feature_importances %>%
      filter(cluster %in% c(cluster_num(), "Total"))
    
    # reshape 
    temp_importances <- dcast(temp_importances, feature ~ cluster, value.var = "importance")
    colnames(temp_importances) <- c("feature", "cluster_value", "total_value")
    
    # compute Ratios
    temp_importances <- temp_importances %>%
      mutate(cluster_value = cluster_value / sum(temp_importances$cluster_value, na.rm = TRUE),
             total_value = total_value / sum(temp_importances$total_value, na.rm = TRUE)) %>%
      arrange(desc(total_value))
    
    temp_importances$feature <- factor(temp_importances$feature, levels = as.vector(temp_importances$feature))
    
    # subset
    temp_importances <- temp_importances[0:25,]
  })
  
  
  
  return(temp_importances())
  
}


