# PSN


## Overview of the Application
This application utilizes patient similarity networks ("PSN") to let the user interactively explore patient subpopulations found in chronic liver disease patients from the MIMIC-III database. In PSNs, each node represents a patient and each edge between two patients represents their similarity for that particular set of data. By measuring similarity between each patient to patient combination across a variety of data subgroups, the application displays a network of patients that is both interpretable and accessible.

The application (contained in the Shiny folder) consists of four tabs:
  * Project Introduction
  * Patient Similarity Networks and Comparisons of Subpopulations
  * 30-day Mortality Prediction Model
  * Survival Analysis 

Initial analysis identifies two core clusters within this population. All default analyses are split based on these two clusters. 

The "Project Introduction" tab contains information related to the overall project including methodology, overview of patient similarity networks, and contents of the application. 

The second tab ("Networks") allows the user to quickly cycle through each of the patient similarity networks and identify what makes the selected cluster unique for that particular subgroup.  For example, if the user is curious about patient medical history, they can display the PSN for medical history and review the results of the statistical tests for just the variables within that specific subgroup. A screenshot of this is displayed below. 
![Networks Tab](./img/networks_tab.JPG)
*Screenshot of the interactive application’s ‘Networks’ tab currently viewing the “medical history” data subgroup. The top left box displays the selected PSN. The two bottom boxes display the statistical test results for numeric (left) and categorical (variables). These are ordered by level of statistical significance. The top right box is left blank because no specific subpopulations have been selected.*

The third tab ("30-day Mortality") displays the results of the 30-day prediction model. A LightGBM model is used to predict whether a patient dies 30 days after their last hospital discharge. 
![Mortality Tab](./img/mortality_tab.JPG)
*Screenshot of the interactive application’s “30-day Mortality” tab, where I display results pertaining to our 30 day mortality prediction model. The top left box displays methodology information. The top right box displays the efficacy results of our prediction model and summary statistics of the percent of patients who die within 30 days and the average time to death for patient. The bottom box displays the mean Shapley values (feature importance scores) for the selected cluster and the total population.*

The fourth and final tab displays the results of a survival analysis.  A survival analysis results in a probability of survival for patients at any given day after their last follow-up.
![Survival Tab](./img/survival_tab.JPG)
*Screenshot of the applications “Survival Analysis” tab, where I display results related to patient subpopulation’s probability of survival at any given point in time after their last hospital discharge. In the top right box, I display a detailed summary of probability of survival for a specific number of days post last discharge – the user has the option to select the number of days. In the bottom left, I display the survival plot and in the bottom right, I display the summary of the Cox regression and the cumulative hazard plot. *


## Exploration Patient Subpopulations

[[summary of methodology]]


Flow of the current analysis:
  1. dataPrep
  2. SimilarityMatrices
  3. graphAnalysis
  4. HEOR

