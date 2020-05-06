A very basic overview of the pre-processing that occurs is:
  * Identify all patients with Chronic Liver Disease
  * Extract relevant data subgroups (e.g., demographics, blood tests, antibody tests)
  * Measure patient pairwise similarity across all subgroups
  * Combine similarity to form the similarity networks 
  * Train a 30-day mortality prediction model
  
The application then evaluates each cluster / subpopulation in real time. Including
  * Identifying relevant features in 30-day mortality 
  * Measuring probability of survival
  * Measuring risk of death