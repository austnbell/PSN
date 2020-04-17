# -*- coding: utf-8 -*-
"""
Created on Thu Apr  9 15:47:59 2020

gets important features using shapley values for a subset of the data
- cleans the data
- extracts shap values 
- computes mean shap values by feature 
- returns data 

@author: Austin Bell
"""

###############################################################################
# Packages

import pandas as pd
import numpy as np
import shap
import pickle


###############################################################################
# Stored Data

# load ML model
with open("../shiny/data/30DayMortality/mortalityModel.pkl", "rb") as f:
    clf = pickle.load(f)

# load shap explainer
with open("../shiny/data/30DayMortality/shapExplainer.pkl", "rb") as f:
    explainer = pickle.load(f)

# load imputers 
with open("../shiny/data/30DayMortality/numImputer.pkl", "rb") as f:
    num_imputer = pickle.load(f)
    
with open("../shiny/data/30DayMortality/catImputer.pkl", "rb") as f:
    cat_imputer = pickle.load(f)


# key columns
cols2keep = ['avg_inr', 'age', 'min_heart_rate', 'max_creatinine', 'avg_potassium',
             'braden_mobility', 'cough_reflex', 'avg_creatinine', 'min_lactate',
             'min_pt', 'avg_heart_rate', 'abdominal_assessment', 'min_bilirubin',
             'min_wgt', 'avg_phosphate', 'min_ast', 'diet_type', 'braden_nutrition',
             'avg_albumin', 'max_lactate', 'avg_lactate', 'min_ptt',
             'min_creatinine', 'incisional', 'max_alt', 'max_heart_rate',
             'avg_resp_rate', 'avg_bilirubin', 'max_resp_rate', 'avg_sodium',
             'avg_alt', 'min_alkph', 'max_bilirubin', 'loss_perc', 'avg_alkph',
             'max_platelet', 'gag_reflex', 'min_ld', 'max_wgt', 'avg_platelet',
             'avg_ld', 'max_albumin', 'max_ld', 'max_pt', 'min_albumin',
             'braden_moisture', 'wgt_change', 'min_resp_rate', 'avg_pt', 'avg_ast',
             'cluster']


cat_vars = ['braden_mobility', 'braden_nutrition', 'diet_type', 'abdominal_assessment',
            'braden_moisture', 'cough_reflex', 'gag_reflex']

###############################################################################
# Pipeline

def dropMissings(df, missing_percent):
    # manual imputes first - i.e., columns where an unknown is justifiable
    df['race']= df.race.fillna("Unknown / Not Specified")
    df['mental_status'] = df.mental_status.fillna(0)
    df['recreational_drug_use'] = df.recreational_drug_use.fillna(0)
    
    # identify the missing columns
    missings = df.isnull().sum() / len(df)
    missing_cols = missings[missings > missing_percent]
    missing_cols = missing_cols.index
    
    # drop missing columns
    df = df.drop(columns = missing_cols)
    
    return df

# convert to pandas categorical
def convertCat(df, cat_vars):
    cat_vars_tmp = [c for c in cat_vars if c in df.columns]
    for col in cat_vars_tmp:
        df[col] = df[col].astype('category')
    return df

def prepData(df, selected_nodes):
    df = dropMissings(df, .5)
    # impute data
    num_df = df.select_dtypes(include='number')
    num_imputed = pd.DataFrame(num_imputer.transform(num_df))
    num_imputed.columns = num_df.columns[~pd.isna(num_imputer.statistics_)]
    
    cat_df = df.select_dtypes(include='object').astype(str)
    cat_imputed = pd.DataFrame(cat_imputer.transform(cat_df))
    cat_imputed.columns = cat_df.columns[~pd.isna(cat_imputer.statistics_)]
    
    df = pd.concat([num_imputed, cat_imputed], axis = 1)
    
    # convert cat columns
    df = convertCat(df, cat_vars)
    
    # subset to selected nodes
    df = df.loc[df['subject_id'].isin(list(selected_nodes))]
    
    # subset to relevant columns
    df = df.loc[:, cols2keep]
    
    return df 
    
# Identify the most important features 
def computeMeanShap(df, selected_nodes, n = 25):
    df = prepData(df, selected_nodes)
    shap_values = explainer.shap_values(df)
    
    # identify top features
    feature_vals = np.abs(shap_values).mean(0).mean(0)
    feat_imps = pd.DataFrame(feature_vals, columns = ['importance'])
    feat_imps['feature'] = df.columns
    feat_imps = feat_imps.sort_values(by = "importance", ascending = False).reset_index(drop = True)
    
    return feat_imps

#keep = [4, 52, 78, 117, 140, 143, 172, 186, 188, 226, 236, 246, 252, 267, 279,
#         292, 314, 329, 357, 366, 393, 422, 433, 452, 480]
    
#df = pd.read_csv("../shiny/data/Patient Level Dataset.csv")

#computeMeanShap(df, keep)

