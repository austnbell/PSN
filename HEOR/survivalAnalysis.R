## Survival Analysis for our clusters
library(survival)
library(survminer)
library(lubridate)
library(tidyverse)
library(ggplot2)
library(knitr)
library(kableExtra)


survival <- patient_df %>%
  select(subject_id, cluster, time2event) %>%
  mutate(years2event = time2event / 365)
survival$survival <- ifelse(is.na(survival$time2event) , 0, 1)
sa <- survfit(Surv(time2event, survival) ~ cluster, data = survival)
sa_total <- survfit(Surv(time2event, survival) ~ 1, data = survival)

fit <- list("Total"= sa_total, "Clusters" = sa)

ggsurvplot_combine(
  fit = fit, 
  xlab = "Days", 
  ylab = "Overall survival probability",
  data = survival,
  risk.table = TRUE)

smry <- summary(sa, times = 2000)
keep = c("time", "n.risk", "n.event", "surv", "std.err", "cumhaz",  "lower", "upper")
cols <- lapply(c(keep,2), function(x) smry[x])
smry <- do.call(data.frame, cols[0:8])
nrow(smry)

cox_smry <- broom::tidy(
  coxph(Surv(time2event, survival) ~ cluster, data = survival), 
  exp = TRUE
) %>%
  knitr::kable("html") %>%
  kable_styling("striped", full_width = F)

ggsurvplot(
  fit = sa, 
  xlab = "Days", 
  ylab = "Overall survival probability",
  fun = "cumhaz")
