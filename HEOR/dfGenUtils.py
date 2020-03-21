# -*- coding: utf-8 -*-
"""
Created on Mon Mar 16 10:21:20 2020

All functions related to generating our data frames for HEOR Analyses

Currently just generates cross-sectional dataframe 

@author: Austin Bell
"""

import numpy as np
import pandas as pd
import re
from functools import reduce
from sklearn.impute import SimpleImputer

# make our categorical data unique by patient
# at the moment, a patient can have multiple observations for categorical data. This function makes it so each patient only has one observation
def convertCategorical(df):
    # identify the modes - using the drop duplicate methods because we only want to select the first
    # This is not a robust method and it is not supposed to be
    # focusing on robustness elsewhere in the analysis 
    collapsed_df = (df.sort_values('frequency', ascending=False)
                    .drop_duplicates(['subject_id','label'])
                    .sort_values(['subject_id', 'label', 'value']))

    pivoted_df = collapsed_df.pivot(index = "subject_id", columns = "label", values = "value")
    del pivoted_df.columns.name

    cols = [re.sub("\\s+", "_", c).lower() for c in pivoted_df.columns]
    pivoted_df.columns = cols
    
    return pivoted_df.reset_index()

# join our all of our relevant datasets into a single dataframe
def genPatientDF(patient_dir, files, cluster_df, mortality_df, time2event = False):
    dfs = []
    for f in files:
        df = pd.read_csv(patient_dir + f)

        if re.search("categorical", f):
            df = convertCategorical(df)

        dfs.append(df)

    # collapse into single dataframe
    patient_df = reduce(lambda left, right : pd.merge(left, right, how = 'left', on = 'subject_id'),
                       dfs)

    # merge our clusters and mortality data
    patient_df = pd.merge(patient_df, cluster_df, how = 'left', on = 'subject_id')
    
    mort_cols = ['subject_id', 'mortality30'] if time2event == False else ['subject_id', 'mortality30', 'time2event']
    patient_df = pd.merge(patient_df, mortality_df[mort_cols], how = 'left', on = 'subject_id')

    return patient_df

# drop columns with a high missing percentage for each dataframe 
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

# impute the remaining missing data
# just using sklearns Imputer 
def imputeMissings(df):
    
    # impute the rest 
    num_imputer = SimpleImputer(strategy = "mean")
    num_df = df.select_dtypes(include='number')
    num_imputed = pd.DataFrame(num_imputer.fit_transform(num_df))
    num_imputed.columns = num_df.columns[~pd.isna(num_imputer.statistics_)] # handles all nan columns 
    
    cat_imputer = SimpleImputer(missing_values = "nan", strategy = "most_frequent") 
    cat_df = df.select_dtypes(include='object').astype(str)
    cat_imputed = pd.DataFrame(cat_imputer.fit_transform(cat_df))
    cat_imputed.columns = cat_df.columns[~pd.isna(cat_imputer.statistics_)]
    
    imputed_df = pd.concat([num_imputed, cat_imputed], axis = 1)
    return imputed_df
