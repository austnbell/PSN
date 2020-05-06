This 30-day mortality prediction leverages a LightGBM Model.
An overview of the training process is as follows.
  * Basic feature engineering including maximums, minimums, averages, first and last values 
  * Drop sparse variables and use mean imputation for other missing data 
  * Fit LightGBM model 
  * Identify top 50 importance features for each and subset our feature data sets
  * Retrain the LightGBM model
  * Evaluate
  * Re-run for 5 cross-validations


The table on the right displays the overall results of each model (averaged across each fold).  
"Total Cluster" represents the combined results of each of the clusters' models. 
The validation set across "Total Cluster" and "Total" are the same set. 


The below graph compares the feature importances via Shapley Values of the selected cluster and the "Total" model. 
It is ordered in descending importance of the selected cluster. If nodes are selected then the feature importances
of the selected nodes will also appear. 


