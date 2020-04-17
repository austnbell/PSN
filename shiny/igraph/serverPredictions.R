## Server code to display the 30 day mortality prediction results
library(tidyverse)


# Summary -----------------------------------------------------------------


predSummary <- function(input, output, session){
  return(datatable(summary_30day,
                   rownames = F,
                   colnames = c("Group / Cluster", "Num. Pts (Train)", "Num. Pts (Val)",
                                "Precision", "Recall", "AUC Score", "F1 Score")) %>%
           formatRound(c(4,5,6,7),2))
}


# Feature Importances -----------------------------------------------------


