This page contains the results of a survival analysis applied to our 
total population and individual clusters. 

On the right is an analysis highlighting the probability of survival 
for a selected number of days after the patient's last hospital discharge. If nodes are selected
in the networks tab, this table also displays survival probability for 
the selected population. 

In the bottom left, we see the results of our survival analysis across
each of our populations. This plot displays probability of survival 
against number of days since the last discharge. If selected, the plot
also includes survival for the selected nodes

In the bottom right, we see the results results from our cox regression
model. In this model, the quantity of interest is the Hazard Ratio. The 
Hazard Ratio can be interpreted as the instantaneous rate of occurrence 
of the event of interest in those who are still at risk for the event.
  * A ratio of <1 represents reduced risk. 
  * Our Hazard Ratio estimate of 1.62 suggest that patients in cluster 1
  are 1.6 times as likely to die as patients in cluster 0
  * If nodes are selected in the networks tab, this analysis compares the
  selected nodes to the total population