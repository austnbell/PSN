library(tidyverse)
library(kableExtra)
library(survival)
library(survminer)


# Summary Table -----------------------------------------------------------


survivalTable <- function(input, output, session, sa, n, days, strata){
  smry <- summary(sa, times = days)
  print(smry)
  keep = c("time", "n.risk", "n.event", "surv", "std.err", "cumhaz",  "lower", "upper")
  cols <- lapply(c(keep,n), function(x) smry[x])
  smry <- do.call(data.frame, cols[0:8])
  validate(
    need(nrow(smry) == n, "Please select a number of days such that there is at least one survivor")
  )
  smry$strata <- strata
  
  return(smry %>% select(strata, everything()))
  
}


# Survival Plot -----------------------------------------------------------


