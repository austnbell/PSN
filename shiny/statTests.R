# server data processing scripts - contains all functions related to cleaning and processing the data
library(tidyverse)

genSampleDFs <- function(patient_df, sg, selected_nodes, g){
  
  selected_pts <- patient_df %>%
    filter(subject_id %in% selected_nodes)
  
  comparison_pts <- patient_df %>%
    filter(!(subject_id %in% selected_nodes) & subject_id %in% names(V(g))) %>%
    sample_n(max(50, nrow(selected_pts)))
  
  if(sg() != "all"){
    sg_cols <- subgroupMapping[[sg()]]
    selected_pts <- selected_pts %>%
      select(sg_cols)
    comparison_pts <- comparison_pts%>%
      select(sg_cols)
      
  } else {
    selected_pts <- selected_pts %>%
      select(-subject_id, -cluster)
    comparison_pts <- comparison_pts%>%
      select(-subject_id, -cluster)
  }
  
  
  return(list(selected_pts, comparison_pts))
}

# run t-tests for numeric columns
tTests <- function(selected_pts, comparison_pts){
  # identify columns
  num_cols = colnames(selected_pts)[  which(sapply(selected_pts, class) %in% c("numeric", "integer"))]
  
  # initialize dataframe 
  num_results = data.frame(variable = character(),
                           cluster_mean = numeric(), 
                           other_mean = numeric(),
                           cluster_std = numeric(),
                           other_std = numeric(),
                           p_value = numeric())
  
  # run statistical tests 
  for(col in num_cols){
    sel_col = selected_pts[!is.na(selected_pts[[col]]),col]
    comp_col = comparison_pts[!is.na(comparison_pts[[col]]),col]
    
    # if not enough samples then skip
    if(length(sel_col) <= 7 | length(comp_col) <= 7){
      next
    }
    
    # compute t-test 
    res = t.test(sel_col, comp_col)
    
    # extract information 
    cluster_mean = res$estimate[[1]]
    other_mean = res$estimate[[2]]
    cluster_std = sd(selected_pts[,col], na.rm = T)
    other_std = sd(comparison_pts[,col], na.rm = T)
    p_value = res$p.value
    
    # add to dataframe 
    num_results <- num_results %>%
      add_row(variable = col, cluster_mean = cluster_mean, other_mean = other_mean, 
              cluster_std = cluster_std, other_std = other_std, p_value = p_value)
    
  }
  
  return(num_results)
}


chi2Tests <- function(selected_pts, comparison_pts){
  
  cat_cols = names(which(sapply(selected_pts, class) == 'character'))
  
  
  # initialize dataframe 
  cat_results = data.frame(variable = character(),
                           primary_label = character(), 
                           primary_cluster_value = numeric(),
                           primary_other_value = numeric(),
                           secondary_label= character(), 
                           secondary_cluster_value = numeric(),
                           secondary_other_value = numeric(),
                           p_value = numeric())
  
  # chisquared tests 
  for(col in cat_cols){
    # get data and frequency ratios
    selected_tbl = table(selected_pts[!is.na(selected_pts[[col]]),col])
    comparison_tbl = table(comparison_pts[!is.na(comparison_pts[[col]]),col])
    
    ctbl = merge(data.frame(selected_tbl), data.frame(comparison_tbl), by = "Var1", all = TRUE)
    ctbl[is.na(ctbl)] <- 0
    
    # ratios
    selected_freq = sort(selected_tbl / sum(selected_tbl), decreasing = T)
    comparison_freq = sort(comparison_tbl / sum(comparison_tbl), decreasing = T)
    
    # extract information
    res = chisq.test(ctbl[,2:3]) 
    p_value = res$p.value
    primary_label = names(selected_freq)[1]
    primary_cluster_value = selected_freq[primary_label][[1]]
    primary_other_value = comparison_freq[primary_label][[1]]
    secondary_label = names(selected_freq)[2]
    secondary_cluster_value = selected_freq[secondary_label][[1]]
    secondary_other_value = comparison_freq[secondary_label][[1]]
    
    # add to dataframe
    cat_results <- cat_results %>%
      add_row(variable = col, primary_label = primary_label, primary_cluster_value = primary_cluster_value,
              primary_other_value = primary_other_value, secondary_label = secondary_label,
              secondary_cluster_value = secondary_cluster_value, secondary_other_value = secondary_other_value,
              p_value = p_value)
  }

  return(cat_results)
}

